defmodule Homebase.Repo do
  use Ecto.Repo,
    otp_app: :homebase,
    adapter: Ecto.Adapters.Postgres
end
