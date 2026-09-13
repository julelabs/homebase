defmodule HomebaseWeb.Plugs.CORS do
  @moduledoc """
  Erlaubt Aufrufe der JSON-API von jeder Origin (SPA bei Cloudflare, Tablet im WLAN).
  Preflight-Anfragen (OPTIONS) werden hier direkt beantwortet.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn =
      conn
      |> put_resp_header("access-control-allow-origin", "*")
      |> put_resp_header("access-control-allow-methods", "GET, PUT, OPTIONS")
      |> put_resp_header("access-control-allow-headers", "content-type, authorization")
      |> put_resp_header("access-control-max-age", "86400")

    if conn.method == "OPTIONS" do
      conn |> send_resp(204, "") |> halt()
    else
      conn
    end
  end
end
