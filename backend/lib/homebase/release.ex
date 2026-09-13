defmodule Homebase.Release do
  @moduledoc "Migrationen und Seeds aus dem Release heraus ausführen (Fly)."
  @app :homebase

  @doc "Migrationen und Seeds, läuft bei jedem Fly-Deploy als release_command."
  def setup do
    migrate()
    seed()
  end

  def migrate do
    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc "Spielt priv/repo/seeds.exs ein (nur wenn noch keine Config existiert)."
  def seed do
    Application.load(@app)
    seeds = Application.app_dir(@app, "priv/repo/seeds.exs")

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _ -> Code.eval_file(seeds) end)
    end
  end
end
