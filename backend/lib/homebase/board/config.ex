defmodule Homebase.Board.Config do
  @moduledoc """
  Übersetzt zwischen den Config-Tabellen und der Form, die das Tablet erwartet:

      %{"kids" => [%{"id" => "k1", "name" => ..., "avatar" => ..., "color" => ...,
                     "literacy" => "icons", "canAddOwn" => true}],
        "tasks" => %{"brotbox" => %{"label" => ..., "short" => ..., "icon" => ...}},
        "activities" => %{"swim" => %{"label" => ..., "morning" => "schwimm_mit",
                                      "eveningBefore" => "schwimm_packen"}},
        "schedule" => %{"k1" => %{"mon" => %{"morning" => [...], "evening" => [...],
                                             "activities" => [...]}}},
        "times" => %{"morningStartsAt" => "06:00", "eveningStartsAt" => "12:00",
                     "nightStartsAt" => "19:00"},
        "sound" => true}

  Aufgaben und Aktivitäten kommen als geordnete Objekte (Position aus der Tabelle).
  Beim Schreiben behalten bekannte Schlüssel ihre Position, neue werden hinten angehängt.
  Verweise auf unbekannte Aufgaben oder Aktivitäten werden still verworfen, so wie es
  das Tablet beim Anzeigen auch tut.
  """

  import Ecto.Query
  alias Ecto.Changeset
  alias Homebase.Repo
  alias Homebase.Board.{Activity, Kid, ScheduleActivity, ScheduleTask, Settings, Task}

  @weekdays ~w(mon tue wed thu fri sat sun)
  @phases ~w(morning evening)

  ## Lesen

  @doc "Die komplette Config oder nil, solange keine Settings-Zeile existiert (nicht geseedet)."
  def load do
    case Repo.one(from s in Settings, limit: 1) do
      nil -> nil
      settings -> build(settings)
    end
  end

  defp build(settings) do
    kids = Repo.all(from k in Kid, order_by: k.position)
    tasks = Repo.all(from t in Task, order_by: t.position)
    activities = Repo.all(from a in Activity, order_by: a.position)

    schedule_tasks =
      Repo.all(from s in ScheduleTask, order_by: s.position)
      |> Enum.group_by(&{&1.kid_id, &1.weekday, &1.phase}, & &1.task_key)

    schedule_activities =
      Repo.all(from a in ScheduleActivity, order_by: a.id)
      |> Enum.group_by(&{&1.kid_id, &1.weekday}, & &1.activity_key)

    schedule =
      Map.new(kids, fn kid ->
        {kid.id,
         Map.new(@weekdays, fn wd ->
           {wd,
            %{
              "morning" => Map.get(schedule_tasks, {kid.id, wd, "morning"}, []),
              "evening" => Map.get(schedule_tasks, {kid.id, wd, "evening"}, []),
              "activities" => Map.get(schedule_activities, {kid.id, wd}, [])
            }}
         end)}
      end)

    %{
      "kids" => Enum.map(kids, &kid_to_map/1),
      "tasks" =>
        Jason.OrderedObject.new(
          for t <- tasks, do: {t.key, %{"label" => t.label, "short" => t.short, "icon" => t.icon}}
        ),
      "activities" =>
        Jason.OrderedObject.new(
          for a <- activities do
            {a.key,
             %{
               "label" => a.label,
               "morning" => a.morning_task_key,
               "eveningBefore" => a.evening_before_task_key
             }}
          end
        ),
      "schedule" => schedule,
      "times" => %{
        "morningStartsAt" => Calendar.strftime(settings.morning_starts_at, "%H:%M"),
        "eveningStartsAt" => Calendar.strftime(settings.evening_starts_at, "%H:%M"),
        "nightStartsAt" => Calendar.strftime(settings.night_starts_at, "%H:%M")
      },
      "sound" => settings.sound
    }
  end

  defp kid_to_map(%Kid{} = k) do
    %{
      "id" => k.id,
      "name" => k.name,
      "avatar" => k.avatar,
      "color" => k.color,
      "literacy" => k.literacy,
      "canAddOwn" => k.can_add_own
    }
  end

  ## Schreiben

  @doc """
  Ersetzt die komplette Config. Gibt {:error, :invalid} bei unbrauchbaren Daten.

  Aufgaben und Aktivitäten dürfen als Map kommen (bekannte Schlüssel behalten ihre Position,
  neue werden angehängt) oder als `Jason.OrderedObject` mit expliziter Reihenfolge (Seeds).
  """
  def replace(
        %{"kids" => kids, "tasks" => tasks, "schedule" => schedule, "times" => times} = data
      )
      when is_list(kids) and is_map(tasks) and is_map(schedule) and is_map(times) do
    activities = data["activities"] || %{}
    sound = if is_nil(data["sound"]), do: true, else: data["sound"]

    with true <- is_map(activities) and is_boolean(sound),
         {:ok, rows} <- validate(kids, tasks, activities, schedule, times, sound),
         {:ok, _} <- write(rows) do
      {:ok, load()}
    else
      _ -> {:error, :invalid}
    end
  end

  def replace(_data), do: {:error, :invalid}

  # Prüft alle Eingaben über die Changesets, bevor irgendetwas geschrieben wird.
  defp validate(kids, tasks, activities, schedule, times, sound) do
    task_keys = tasks |> Map.new() |> Map.keys() |> MapSet.new()
    activity_keys = activities |> Map.new() |> Map.keys() |> MapSet.new()

    with {:ok, kid_rows} <- rows(kids |> Enum.with_index(), &kid_changeset/1),
         {:ok, task_rows} <- rows(ordered(tasks, positions(Task)), &task_changeset/1),
         {:ok, activity_rows} <-
           rows(ordered(activities, positions(Activity)), &activity_changeset(&1, task_keys)),
         {:ok, settings} <- settings_changeset(times, sound) do
      kid_ids = MapSet.new(kid_rows, & &1.id)

      {:ok,
       %{
         kids: kid_rows,
         tasks: task_rows,
         activities: activity_rows,
         schedule: schedule_rows(schedule, kid_ids, task_keys, activity_keys),
         settings: settings
       }}
    end
  end

  defp rows(items, to_changeset) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, acc} ->
      case Changeset.apply_action(to_changeset.(item), :insert) do
        {:ok, struct} -> {:cont, {:ok, acc ++ [struct]}}
        {:error, _} -> {:halt, {:error, :invalid}}
      end
    end)
  end

  defp kid_changeset({kid, position}) when is_map(kid) do
    %Kid{position: position}
    |> Kid.changeset(%{
      id: kid["id"],
      name: kid["name"],
      avatar: kid["avatar"],
      color: kid["color"],
      literacy: kid["literacy"],
      can_add_own: Map.get(kid, "canAddOwn", true)
    })
  end

  defp kid_changeset(_), do: Changeset.change(%Kid{}) |> Changeset.add_error(:id, "kein Objekt")

  defp task_changeset({key, task, position}) when is_map(task) do
    %Task{position: position}
    |> Task.changeset(%{key: key, label: task["label"], short: task["short"], icon: task["icon"]})
  end

  defp task_changeset(_),
    do: Changeset.change(%Task{}) |> Changeset.add_error(:key, "kein Objekt")

  # Verweise auf gelöschte Aufgaben werden geleert statt die ganze Config abzulehnen.
  defp activity_changeset({key, act, position}, task_keys) when is_map(act) do
    known = fn k -> if MapSet.member?(task_keys, k), do: k end

    %Activity{position: position}
    |> Activity.changeset(%{
      key: key,
      label: act["label"],
      morning_task_key: known.(act["morning"]),
      evening_before_task_key: known.(act["eveningBefore"])
    })
  end

  defp activity_changeset(_, _),
    do: Changeset.change(%Activity{}) |> Changeset.add_error(:key, "kein Objekt")

  defp settings_changeset(times, sound) do
    attrs = %{
      morning_starts_at: times["morningStartsAt"],
      evening_starts_at: times["eveningStartsAt"],
      night_starts_at: times["nightStartsAt"],
      sound: sound
    }

    case Changeset.apply_action(Settings.changeset(%Settings{}, attrs), :insert) do
      {:ok, _} -> {:ok, attrs}
      {:error, _} -> {:error, :invalid}
    end
  end

  defp schedule_rows(schedule, kid_ids, task_keys, activity_keys) do
    entries =
      for {kid_id, days} <- schedule,
          MapSet.member?(kid_ids, kid_id),
          is_map(days),
          {wd, day} <- days,
          wd in @weekdays,
          is_map(day),
          do: {kid_id, wd, day}

    tasks =
      for {kid_id, wd, day} <- entries,
          phase <- @phases,
          {task_key, position} <- Enum.with_index(List.wrap(day[phase])),
          MapSet.member?(task_keys, task_key),
          do: %{kid_id: kid_id, weekday: wd, phase: phase, task_key: task_key, position: position}

    activities =
      for {kid_id, wd, day} <- entries,
          act_key <- List.wrap(day["activities"]),
          MapSet.member?(activity_keys, act_key),
          do: %{kid_id: kid_id, weekday: wd, activity_key: act_key}

    %{
      tasks: Enum.uniq_by(tasks, &{&1.kid_id, &1.weekday, &1.phase, &1.task_key}),
      activities: Enum.uniq(activities)
    }
  end

  # Alles in einer Transaktion ersetzen. Wochenplan-Zeilen fallen über die Fremdschlüssel mit weg.
  # Der Advisory-Lock reiht überlappende Schreibvorgänge hintereinander, sonst kollidiert
  # das Neu-Einfügen mit den Primärschlüsseln des noch nicht abgeschlossenen Vorgängers.
  @config_lock 1

  defp write(rows) do
    Repo.transaction(fn ->
      Repo.query!("SELECT pg_advisory_xact_lock($1)", [@config_lock])
      Repo.delete_all(Kid)
      Repo.delete_all(Activity)
      Repo.delete_all(Task)

      Repo.insert_all(Kid, Enum.map(rows.kids, &struct_to_row(&1, Kid)))
      Repo.insert_all(Task, Enum.map(rows.tasks, &struct_to_row(&1, Task)))
      Repo.insert_all(Activity, Enum.map(rows.activities, &struct_to_row(&1, Activity)))
      Repo.insert_all(ScheduleTask, rows.schedule.tasks)
      Repo.insert_all(ScheduleActivity, rows.schedule.activities)

      settings = Repo.one(from s in Settings, limit: 1) || %Settings{}
      Repo.insert_or_update!(Settings.changeset(settings, rows.settings))
    end)
  end

  defp struct_to_row(struct, schema) do
    Map.take(struct, schema.__schema__(:fields))
  end

  defp positions(schema) do
    Repo.all(from r in schema, select: {r.key, r.position}) |> Map.new()
  end

  # Explizite Reihenfolge: Position ist der Index.
  defp ordered(%Jason.OrderedObject{values: values}, _existing) do
    Enum.with_index(values, fn {k, v}, i -> {k, v, i} end)
  end

  # Bekannte Schlüssel behalten ihre Position, neue kommen dahinter in Schlüsselreihenfolge.
  defp ordered(map, existing) do
    next = (existing |> Map.values() |> Enum.max(fn -> -1 end)) + 1
    {known, new} = Enum.split_with(map, fn {k, _} -> Map.has_key?(existing, k) end)

    known =
      known
      |> Enum.sort_by(fn {k, _} -> existing[k] end)
      |> Enum.map(fn {k, v} -> {k, v, existing[k]} end)

    new =
      new
      |> Enum.sort_by(fn {k, _} -> k end)
      |> Enum.with_index(fn {k, v}, i -> {k, v, next + i} end)

    known ++ new
  end
end
