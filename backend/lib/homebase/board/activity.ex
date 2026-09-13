defmodule Homebase.Board.Activity do
  @moduledoc """
  Eine Aktivität wie Schwimmen: am Tag selbst steht morgens die Mitnehmen-Aufgabe an,
  am Abend davor die Pack-Aufgabe.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :string, autogenerate: false}
  schema "activities" do
    field :label, :string
    field :morning_task_key, :string
    field :evening_before_task_key, :string
    field :position, :integer
    timestamps(type: :utc_datetime)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:key, :label, :morning_task_key, :evening_before_task_key, :position])
    |> validate_required([:key, :label, :position])
    |> foreign_key_constraint(:morning_task_key)
    |> foreign_key_constraint(:evening_before_task_key)
  end
end
