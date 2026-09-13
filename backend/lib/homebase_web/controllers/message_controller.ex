defmodule HomebaseWeb.MessageController do
  use HomebaseWeb, :controller

  alias Homebase.Board
  alias HomebaseWeb.BoardController

  action_fallback HomebaseWeb.FallbackController

  def update(conn, %{"date" => date} = params) do
    with {:ok, date} <- BoardController.parse_date(date),
         {:ok, message} <- Board.put_message(date, Map.get(params, "text", "")) do
      json(conn, %{message: message})
    end
  end
end
