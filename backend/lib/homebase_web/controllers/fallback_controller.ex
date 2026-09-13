defmodule HomebaseWeb.FallbackController do
  @moduledoc "Übersetzt Fehler-Tupel der Controller in JSON-Antworten."
  use HomebaseWeb, :controller

  def call(conn, {:error, :invalid}) do
    conn |> put_status(422) |> json(%{errors: %{detail: "Ungültige Daten"}})
  end

  def call(conn, {:error, :bad_date}) do
    conn |> put_status(400) |> json(%{errors: %{detail: "Datum muss YYYY-MM-DD sein"}})
  end
end
