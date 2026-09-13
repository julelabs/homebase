defmodule HomebaseWeb.ApiTest do
  use HomebaseWeb.ConnCase, async: false

  @config %{
    "kids" => [
      %{
        "id" => "k1",
        "name" => "Anna",
        "avatar" => "fox",
        "color" => "salbei",
        "literacy" => "icons",
        "canAddOwn" => true
      }
    ],
    "tasks" => %{
      "zaehne" => %{"label" => "Zähne putzen", "short" => "Zähne", "icon" => "toothbrush"}
    },
    "activities" => %{},
    "schedule" => %{
      "k1" => %{"mon" => %{"morning" => ["zaehne"], "evening" => [], "activities" => []}}
    },
    "times" => %{
      "morningStartsAt" => "06:00",
      "eveningStartsAt" => "12:00",
      "nightStartsAt" => "19:00"
    },
    "sound" => true
  }

  test "GET /api/board returns config, day and message for the date", %{conn: conn} do
    conn = get(conn, ~p"/api/board?date=2026-09-13")

    assert %{"config" => nil, "message" => nil, "day" => %{"date" => "2026-09-13"}} =
             json_response(conn, 200)
  end

  test "GET /api/board without a valid date is a 400", %{conn: conn} do
    assert json_response(get(conn, ~p"/api/board?date=gestern"), 400)
    assert json_response(get(conn, ~p"/api/board"), 400)
  end

  test "PUT /api/config stores the config", %{conn: conn} do
    conn = put(conn, ~p"/api/config", %{"config" => @config})
    assert %{"config" => config} = json_response(conn, 200)
    assert config["kids"] == @config["kids"]
    assert config["tasks"] == @config["tasks"]
    assert config["schedule"]["k1"]["mon"] == @config["schedule"]["k1"]["mon"]

    assert config["schedule"]["k1"]["sun"] == %{
             "morning" => [],
             "evening" => [],
             "activities" => []
           }
  end

  test "PUT /api/config with an incomplete config is a 422", %{conn: conn} do
    conn = put(conn, ~p"/api/config", %{"config" => %{"kids" => []}})
    assert json_response(conn, 422)
  end

  test "PUT /api/days/:date and PUT /api/messages/:date round trip", %{conn: conn} do
    day = %{"checked" => %{"k1" => %{"brotbox" => true}}, "own" => %{}}

    assert %{"day" => %{"checked" => %{"k1" => %{"brotbox" => true}}}} =
             json_response(put(conn, ~p"/api/days/2026-09-13", day), 200)

    assert %{"message" => %{"text" => "Hallo"}} =
             json_response(put(conn, ~p"/api/messages/2026-09-13", %{"text" => "Hallo"}), 200)

    board = json_response(get(conn, ~p"/api/board?date=2026-09-13"), 200)
    assert board["day"]["checked"] == %{"k1" => %{"brotbox" => true}}
    assert board["message"]["text"] == "Hallo"
  end

  test "OPTIONS preflight is answered with CORS headers", %{conn: conn} do
    conn = options(conn, ~p"/api/board")
    assert conn.status == 204
    assert get_resp_header(conn, "access-control-allow-origin") == ["*"]
  end

  test "API token protects every route when configured, health stays open", %{conn: conn} do
    Application.put_env(:homebase, :api_token, "geheim")
    on_exit(fn -> Application.delete_env(:homebase, :api_token) end)

    assert json_response(get(conn, ~p"/api/board?date=2026-09-13"), 401)
    assert json_response(get(conn, ~p"/health"), 200) == %{"status" => "ok"}

    conn = put_req_header(conn, "authorization", "Bearer geheim")
    assert json_response(get(conn, ~p"/api/board?date=2026-09-13"), 200)
  end
end
