defmodule HomebaseWeb.Router do
  use HomebaseWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug HomebaseWeb.Plugs.Auth
  end

  scope "/api", HomebaseWeb do
    pipe_through :api

    # Alles für den Start des Tablets: Config, Tageszustand, Nachricht
    get "/board", BoardController, :show
    # Config komplett ersetzen
    put "/config", ConfigController, :update
    # Haken und eigene Aufgaben eines Tages komplett ersetzen
    put "/days/:date", DayController, :update
    # Nachricht eines Tages setzen, leerer Text löscht
    put "/messages/:date", MessageController, :update
  end
end
