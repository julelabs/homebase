defmodule Homebase.Release do
  @moduledoc "Migrationen und Seeds aus dem Release heraus ausführen (Fly release_command)."
  @app :homebase

  @doc "Migrationen ausführen, danach priv/repo/seeds.exs (legt die Config nur an, wenn keine existiert)."
  def setup do
    Application.load(@app)
    seeds = Application.app_dir(@app, "priv/repo/seeds.exs")

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          Ecto.Migrator.run(repo, :up, all: true)
          Code.eval_file(seeds)
        end)
    end
  end
end
