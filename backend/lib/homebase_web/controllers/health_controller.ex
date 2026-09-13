defmodule HomebaseWeb.HealthController do
  @moduledoc "Lebenszeichen ohne Token und ohne Datenbank, zum Aufwecken und für Checks."
  use HomebaseWeb, :controller

  def show(conn, _params), do: json(conn, %{status: "ok"})
end
