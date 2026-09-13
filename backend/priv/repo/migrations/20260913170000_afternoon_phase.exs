defmodule Homebase.Repo.Migrations.AfternoonPhase do
  use Ecto.Migration

  # Dritter Zeitraum: Mittags (nach der Schule) zwischen Morgens und Abends.
  # Bestehende Einstellungen: Mittagsliste ab 12:00, die Abendliste rückt auf 17:00,
  # wenn sie bisher auf der alten Grenze (12:00) lag. Wochenplan-Zeilen für "afternoon"
  # entstehen erst, wenn im Elternbereich Aufgaben zugewiesen werden.
  def up do
    alter table(:settings) do
      add :afternoon_starts_at, :time, null: false, default: fragment("'12:00:00'::time")
    end

    execute "UPDATE settings SET evening_starts_at = '17:00:00' WHERE evening_starts_at <= '12:00:00'"
  end

  def down do
    execute "DELETE FROM schedule_tasks WHERE phase = 'afternoon'"
    execute "DELETE FROM own_tasks WHERE phase = 'afternoon'"

    alter table(:settings) do
      remove :afternoon_starts_at
    end
  end
end
