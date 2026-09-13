defmodule HomebaseWeb.DayController do
  use HomebaseWeb, :controller

  alias Homebase.Board
  alias HomebaseWeb.BoardController

  action_fallback HomebaseWeb.FallbackController

  def update(conn, %{"date" => date} = params) do
    with {:ok, date} <- BoardController.parse_date(date),
         {:ok, day} <- Board.put_day(date, params) do
      json(conn, %{day: day})
    end
  end
end
