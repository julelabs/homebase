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
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:key, :label, :morning_task_key, :evening_before_task_key])
    |> validate_required([:key, :label])
    |> validate_length(:key, max: 40)
    |> validate_length(:label, max: 60)
  end
end
