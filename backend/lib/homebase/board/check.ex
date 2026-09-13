defmodule Homebase.Board.Check do
  @moduledoc "Ein gesetzter Haken: Kind, Aufgabe, Tag."
  use Ecto.Schema

  schema "checks" do
    field :date, :date
    field :kid_id, :string
    field :task_key, :string
    timestamps(type: :utc_datetime, updated_at: false)
  end
end
