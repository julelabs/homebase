defmodule HomebaseWeb.Plugs.Auth do
  @moduledoc """
  Optionaler Schutz der API mit einem gemeinsamen Token (Umgebungsvariable API_TOKEN).
  Ohne gesetztes Token ist die API offen. Der Client schickt das Token als
  `Authorization: Bearer <token>`.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Application.get_env(:homebase, :api_token) do
      nil -> conn
      "" -> conn
      token -> check(conn, token)
    end
  end

  defp check(conn, token) do
    if get_req_header(conn, "authorization") == ["Bearer " <> token] do
      conn
    else
      conn
      |> put_status(401)
      |> Phoenix.Controller.json(%{errors: %{detail: "Unauthorized"}})
      |> halt()
    end
  end
end
