import copy
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("deploy", Path(__file__).parents[1] / "deploy.py")
deploy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(deploy)

DIGEST = "sha256:" + "a" * 64
TAG = "b" * 40
APP = {
    "name": "homebase-api",
    "autoScaling": {"min": 1, "max": 1},
    "regionSettings": {"allowedRegionIds": ["DE"], "requiredRegionIds": ["DE"]},
    "volumes": [],
    "containerTemplates": [{
        "id": "container",
        "imageNamespace": "julelabs", "imageName": "homebase-api", "imageDigest": "old",
        "environmentVariables": [
            {"name": "DATABASE_URL", "value": "ecto://existing-database"},
            {"name": "SECRET_KEY_BASE", "value": "existing-key"},
            {"name": "API_TOKEN", "value": "existing-token"},
        ],
    }],
}
CONFIG = {"app_id": "app", "url": "https://example.bunny.run"}


def overview(name):
    return {"status": "active", "regions": [{"pods": [{"name": name, "status": "ready"}]}]}


class DeployTest(unittest.TestCase):
    @patch.dict("os.environ", {"IMAGE_TAG": TAG, "IMAGE_DIGEST": DIGEST})
    @patch.object(deploy, "check_http")
    @patch.object(deploy, "api")
    def test_deployment_patches_only_image_and_verifies_database(self, api, check_http):
        live = copy.deepcopy(APP)
        live["containerTemplates"][0]["imageDigest"] = DIGEST
        api.side_effect = [APP, overview("old"), None, overview("new"), live]
        deploy.deploy(CONFIG)
        self.assertEqual(api.call_args_list[2].args, (
            "PATCH", "/mc/apps/app/containers/container",
            {"imageTag": TAG, "imageDigest": DIGEST, "imagePullPolicy": "always"},
        ))
        check_http.assert_called_once_with(CONFIG["url"], "existing-token")

    @patch.object(deploy, "check_http")
    @patch.object(deploy, "api")
    def test_check_only_never_changes_app(self, api, check_http):
        api.side_effect = [APP, overview("current")]
        deploy.deploy(CONFIG, check_only=True)
        self.assertTrue(all(call.args[0] == "GET" for call in api.call_args_list))
        check_http.assert_called_once()

    @patch.dict("os.environ", {"IMAGE_TAG": TAG, "IMAGE_DIGEST": DIGEST})
    @patch.object(deploy, "check_http")
    @patch.object(deploy, "api")
    def test_unchanged_digest_does_not_restart(self, api, check_http):
        live = copy.deepcopy(APP)
        live["containerTemplates"][0]["imageDigest"] = DIGEST
        api.side_effect = [live, overview("current")]
        deploy.deploy(CONFIG)
        self.assertTrue(all(call.args[0] == "GET" for call in api.call_args_list))

    @patch.object(deploy, "api")
    def test_unexpected_app_is_rejected_before_mutation(self, api):
        app = copy.deepcopy(APP)
        app["name"] = "another-app"
        api.return_value = app
        with self.assertRaisesRegex(RuntimeError, "Unexpected Bunny app"):
            deploy.deploy(CONFIG)
        api.assert_called_once_with("GET", "/mc/apps/app")
