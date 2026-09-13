defmodule Homebase.Repo.Migrations.CreateBoardTables do
  use Ecto.Migration

  def change do
    # Die komplette Board-Konfiguration (Kinder, Aufgaben, Wochenplan, Zeiten)
    # als ein JSON-Dokument. Es gibt genau eine Zeile.
    create table(:configs) do
      add :data, :map, null: false
      timestamps(type: :utc_datetime)
    end

    # Ein Haken pro Kind, Aufgabe und Tag.
    create table(:checks) do
      add :date, :date, null: false
      add :kid_id, :string, null: false
      add :task_key, :string, null: false
      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:checks, [:date, :kid_id, :task_key])

    # Eigene Aufgaben der Kinder, gelten nur an ihrem Tag. Die ID kommt vom Client.
    create table(:own_tasks, primary_key: false) do
      add :id, :string, primary_key: true
      add :date, :date, null: false
      add :kid_id, :string, null: false
      add :phase, :string, null: false
      add :icon, :string, null: false
      add :label, :string, null: false
      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:own_tasks, [:date])

    # Die Nachricht der Eltern, eine pro Tag.
    create table(:messages) do
      add :date, :date, null: false
      add :text, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:messages, [:date])
  end
end
