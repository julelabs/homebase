defmodule Homebase.Board.ScheduleActivity do
  @moduledoc "Wochenplan-Eintrag: Aktivität für ein Kind an einem Wochentag."
  use Ecto.Schema

  schema "schedule_activities" do
    field :kid_id, :string
    field :weekday, :string
    field :activity_key, :string
  end
end
