#!/usr/bin/env python3
"""Deploy a pinned image to the existing Bunny app, preserving its secrets."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request

CONFIG = Path(__file__).resolve().parents[1] / "bunny.json"


def api(method, path, body=None):
    # App responses contain database credentials. Never print them or API errors.
    result = subprocess.run(
        ["bunny", "api", method, path],
        input=json.dumps(body) if body is not None else "",
        capture_output=True,
        text=True,
        timeout=60,
    )
    if result.returncode:
        raise RuntimeError(f"Bunny API request failed: {method} {path}")
    return json.loads(result.stdout) if result.stdout.strip() else None


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def validate_app(app):
    require(app["name"] == "homebase-api", "Unexpected Bunny app.")
    require(app["autoScaling"] == {"min": 1, "max": 1}, "Expected one replica.")
    for key in ("allowedRegionIds", "requiredRegionIds"):
        require(app["regionSettings"][key] == ["DE"], "Expected Germany region.")
    require(not app["volumes"], "Postgres is external; no volumes expected.")
    require(len(app["containerTemplates"]) == 1, "Expected one container.")
    container = app["containerTemplates"][0]
    require(
        (container["imageNamespace"], container["imageName"]) == ("julelabs", "homebase-api"),
        "Unexpected container image.",
    )
    environment = {item["name"]: item["value"] for item in container["environmentVariables"]}
    for name in ("DATABASE_URL", "SECRET_KEY_BASE"):
        require(bool(environment.get(name)), f"Missing {name} on Bunny.")
    return container, environment


def ready_pod(overview):
    pods = [pod for region in overview["regions"] for pod in region["pods"]]
    if overview["status"] == "active" and len(pods) == 1 and pods[0]["status"] == "ready":
        return pods[0]["name"]
    return None


def check_http(url, token):
    headers = {"Cache-Control": "no-cache"}
    if token:
        headers["Authorization"] = "Bearer " + token
    # The board endpoint verifies connectivity to the existing database as well.
    for path, expected in (("/health", "status"), ("/api/board", "config")):
        request = urllib.request.Request(url + path, headers=headers)
        for attempt in range(10):
            try:
                with urllib.request.urlopen(request, timeout=20) as response:
                    require(response.status == 200, f"HTTP check failed: {path}")
                    require(expected in json.load(response), f"Unexpected response: {path}")
                break
            except (urllib.error.URLError, TimeoutError):
                if attempt == 9:
                    raise RuntimeError(f"HTTP check failed: {path}") from None
                time.sleep(3)


def deploy(config, check_only=False):
    base = "/mc/apps/" + config["app_id"]
    container, environment = validate_app(api("GET", base))
    old_pod = ready_pod(api("GET", base + "/overview"))
    require(old_pod is not None, "App must be healthy before deploying.")
    if not check_only:
        tag, digest = os.environ["IMAGE_TAG"], os.environ["IMAGE_DIGEST"]
        require(re.fullmatch(r"[0-9a-f]{40}", tag), "Expected a full commit SHA.")
        require(re.fullmatch(r"sha256:[0-9a-f]{64}", digest), "Expected an image digest.")
        if container["imageDigest"] != digest:
            # Patch only the image. Database URL, signing key, and optional API
            # token remain in Bunny and never need to pass through GitHub Actions.
            api("PATCH", base + "/containers/" + container["id"], {
                "imageTag": tag, "imageDigest": digest, "imagePullPolicy": "always",
            })
            print(f"Deploying {tag} ({digest}).", flush=True)
            deadline = time.monotonic() + 900
            while time.monotonic() < deadline:
                pod = ready_pod(api("GET", base + "/overview"))
                if pod and pod != old_pod:
                    live, current_env = validate_app(api("GET", base))
                    require(live["imageDigest"] == digest, "Image changed unexpectedly.")
                    require(current_env == environment, "Environment changed unexpectedly.")
                    break
                time.sleep(5)
            else:
                raise RuntimeError("Deployment timed out. Inspect Bunny before retrying.")
    check_http(config["url"], environment.get("API_TOKEN"))
    print(f"Verified healthy backend and database access: {config['url']}", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify without deploying")
    args = parser.parse_args()
    try:
        deploy(json.loads(CONFIG.read_text()), args.check)
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
