defmodule HomebaseWeb.BoardController do
  @moduledoc "Liefert alles, was das Tablet zum Start braucht, in einer Antwort."
  use HomebaseWeb, :controller

  alias Homebase.Board

  action_fallback HomebaseWeb.FallbackController

  def show(conn, %{"date" => date}) do
    with {:ok, date} <- parse_date(date) do
      json(conn, %{
        config: Board.get_config(),
        day: Board.get_day(date),
        message: Board.get_message(date)
      })
    end
  end

  def show(_conn, _params), do: {:error, :bad_date}

  @doc "Parst YYYY-MM-DD aus der URL."
  def parse_date(string) when is_binary(string) do
    case Date.from_iso8601(string) do
      {:ok, date} -> {:ok, date}
      _ -> {:error, :bad_date}
    end
  end

  def parse_date(_), do: {:error, :bad_date}
end
