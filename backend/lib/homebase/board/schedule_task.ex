defmodule Homebase.Board.ScheduleTask do
  @moduledoc "Wochenplan-Eintrag: Aufgabe für ein Kind an einem Wochentag, morgens oder abends."
  use Ecto.Schema

  schema "schedule_tasks" do
    field :kid_id, :string
    field :weekday, :string
    field :phase, :string
    field :task_key, :string
    field :position, :integer
  end
end
