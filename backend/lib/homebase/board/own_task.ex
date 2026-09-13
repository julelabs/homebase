defmodule Homebase.Board.OwnTask do
  @moduledoc "Eine vom Kind selbst angelegte Aufgabe, gilt nur an ihrem Tag."
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "own_tasks" do
    field :date, :date
    field :kid_id, :string
    field :phase, :string
    field :icon, :string
    field :label, :string
    timestamps(type: :utc_datetime, updated_at: false)
  end
end
