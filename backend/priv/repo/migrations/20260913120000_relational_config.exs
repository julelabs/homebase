defmodule Homebase.Repo.Migrations.RelationalConfig do
  use Ecto.Migration

  # Die Board-Config wandert vom JSON-Dokument in eigene Tabellen.
  # Der bisherige Inhalt war nur die Default-Config aus dem Prototyp, die kommt jetzt aus den Seeds.
  def up do
    drop table(:configs)

    create table(:kids, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :avatar, :string, null: false
      add :color, :string, null: false
      add :literacy, :string, null: false
      add :can_add_own, :boolean, null: false, default: true
      add :position, :integer, null: false
    end

    create table(:tasks, primary_key: false) do
      add :key, :string, primary_key: true
      add :label, :string, null: false
      add :short, :string, null: false
      add :icon, :string, null: false
      add :position, :integer, null: false
    end

    # Eine Aktivität (Schwimmen, Sport) erzeugt morgens eine Aufgabe und am Abend davor eine Pack-Aufgabe.
    create table(:activities, primary_key: false) do
      add :key, :string, primary_key: true
      add :label, :string, null: false

      add :morning_task_key,
          references(:tasks, column: :key, type: :string, on_delete: :nilify_all)

      add :evening_before_task_key,
          references(:tasks, column: :key, type: :string, on_delete: :nilify_all)

      add :position, :integer, null: false
    end

    # Wochenplan: welche Aufgabe an welchem Wochentag morgens oder abends für ein Kind ansteht.
    create table(:schedule_tasks) do
      add :kid_id, references(:kids, type: :string, on_delete: :delete_all), null: false
      add :weekday, :string, null: false
      add :phase, :string, null: false

      add :task_key, references(:tasks, column: :key, type: :string, on_delete: :delete_all),
        null: false

      add :position, :integer, null: false
    end

    create unique_index(:schedule_tasks, [:kid_id, :weekday, :phase, :task_key])

    create table(:schedule_activities) do
      add :kid_id, references(:kids, type: :string, on_delete: :delete_all), null: false
      add :weekday, :string, null: false

      add :activity_key,
          references(:activities, column: :key, type: :string, on_delete: :delete_all),
          null: false
    end

    create unique_index(:schedule_activities, [:kid_id, :weekday, :activity_key])

    # Genau eine Zeile: Umschaltzeiten und Feiersound.
    create table(:settings) do
      add :morning_starts_at, :time, null: false
      add :evening_starts_at, :time, null: false
      add :night_starts_at, :time, null: false
      add :sound, :boolean, null: false, default: true
      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop table(:settings)
    drop table(:schedule_activities)
    drop table(:schedule_tasks)
    drop table(:activities)
    drop table(:tasks)
    drop table(:kids)

    create table(:configs) do
      add :data, :map, null: false
      timestamps(type: :utc_datetime)
    end
  end
end
