defmodule Homebase.Board.Task do
  @moduledoc "Eine wiederkehrende Aufgabe, zum Beispiel Brotbox in die Küche."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :string, autogenerate: false}
  schema "tasks" do
    field :label, :string
    # Kurzform unter dem Icon-Tile
    field :short, :string
    field :icon, :string
    field :position, :integer
    timestamps(type: :utc_datetime)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:key, :label, :short, :icon, :position])
    |> validate_required([:key, :label, :short, :icon, :position])
    |> validate_length(:label, max: 60)
    |> validate_length(:short, max: 20)
  end
end
