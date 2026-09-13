defmodule HomebaseWeb.ConfigController do
  use HomebaseWeb, :controller

  alias Homebase.Board

  action_fallback HomebaseWeb.FallbackController

  def update(conn, %{"config" => data}) when is_map(data) do
    with {:ok, data} <- Board.put_config(data) do
      json(conn, %{config: data})
    end
  end

  def update(_conn, _params), do: {:error, :invalid}
end
