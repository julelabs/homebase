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
  """

  import Ecto.Query
  alias Homebase.Repo
  alias Homebase.Board.{Activity, Kid, ScheduleActivity, ScheduleTask, Settings, Task}

  @weekdays ~w(mon tue wed thu fri sat sun)
  @phases ~w(morning evening)

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
    schedule_tasks = Repo.all(from s in ScheduleTask, order_by: s.position)
    schedule_activities = Repo.all(ScheduleActivity)

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
      "schedule" => build_schedule(kids, schedule_tasks, schedule_activities),
      "times" => %{
        "morningStartsAt" => time_out(settings.morning_starts_at),
        "eveningStartsAt" => time_out(settings.evening_starts_at),
        "nightStartsAt" => time_out(settings.night_starts_at)
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

  defp build_schedule(kids, schedule_tasks, schedule_activities) do
    Map.new(kids, fn kid ->
      days =
        Map.new(@weekdays, fn wd ->
          tasks_for = fn phase ->
            for s <- schedule_tasks,
                s.kid_id == kid.id and s.weekday == wd and s.phase == phase,
                do: s.task_key
          end

          acts =
            for a <- schedule_activities,
                a.kid_id == kid.id and a.weekday == wd,
                do: a.activity_key

          {wd,
           %{
             "morning" => tasks_for.("morning"),
             "evening" => tasks_for.("evening"),
             "activities" => acts
           }}
        end)

      {kid.id, days}
    end)
  end

  @doc """
  Ersetzt die komplette Config. Gibt {:error, :invalid} bei unbrauchbaren Daten.

  Aufgaben und Aktivitäten dürfen als Map kommen (bekannte Schlüssel behalten ihre Position,
  neue werden angehängt) oder als `Jason.OrderedObject` mit expliziter Reihenfolge (Seeds).
  """
  def replace(
        %{"kids" => kids, "tasks" => tasks, "schedule" => schedule, "times" => times} = data
      )
      when is_list(kids) and is_map(tasks) and is_map(schedule) and is_map(times) do
    activities = Map.get(data, "activities") || %{}
    sound = Map.get(data, "sound", true)

    with true <- is_map(activities) and is_boolean(sound),
         {:ok, times} <- parse_times(times) do
      task_map = to_map(tasks)
      activity_map = to_map(activities)

      result =
        Repo.transaction(fn ->
          existing_task_positions = positions(Task, :key)
          existing_activity_positions = positions(Activity, :key)

          Repo.delete_all(ScheduleTask)
          Repo.delete_all(ScheduleActivity)
          Repo.delete_all(Activity)
          Repo.delete_all(Task)
          Repo.delete_all(Kid)

          kids |> Enum.with_index() |> Enum.each(&insert_kid!/1)
          tasks |> ordered(existing_task_positions) |> Enum.each(&insert_task!/1)
          activities |> ordered(existing_activity_positions) |> Enum.each(&insert_activity!/1)
          insert_schedule!(schedule, kids, task_map, activity_map)

          settings = Repo.one(from s in Settings, limit: 1) || %Settings{}
          Repo.insert_or_update!(Settings.changeset(settings, Map.put(times, :sound, sound)))
        end)

      case result do
        {:ok, _} -> {:ok, load()}
        {:error, _} -> {:error, :invalid}
      end
    else
      _ -> {:error, :invalid}
    end
  rescue
    _ in [Ecto.InvalidChangesetError, Ecto.ConstraintError, FunctionClauseError, ArgumentError] ->
      {:error, :invalid}
  end

  def replace(_data), do: {:error, :invalid}

  defp positions(schema, key_field) do
    Repo.all(from r in schema, select: {field(r, ^key_field), r.position}) |> Map.new()
  end

  defp to_map(%Jason.OrderedObject{values: values}), do: Map.new(values)
  defp to_map(map) when is_map(map), do: map

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

  defp insert_kid!({kid, position}) when is_map(kid) do
    Repo.insert!(
      Kid.changeset(%Kid{}, %{
        id: kid["id"],
        name: kid["name"],
        avatar: kid["avatar"],
        color: kid["color"],
        literacy: kid["literacy"],
        can_add_own: Map.get(kid, "canAddOwn", true),
        position: position
      })
    )
  end

  defp insert_task!({key, task, position}) when is_map(task) do
    Repo.insert!(
      Task.changeset(%Task{}, %{
        key: key,
        label: task["label"],
        short: task["short"],
        icon: task["icon"],
        position: position
      })
    )
  end

  defp insert_activity!({key, act, position}) when is_map(act) do
    Repo.insert!(
      Activity.changeset(%Activity{}, %{
        key: key,
        label: act["label"],
        morning_task_key: act["morning"],
        evening_before_task_key: act["eveningBefore"],
        position: position
      })
    )
  end

  defp insert_schedule!(schedule, kids, tasks, activities) do
    kid_ids = Enum.map(kids, & &1["id"])

    for {kid_id, days} <- schedule,
        kid_id in kid_ids,
        is_map(days),
        {wd, day} <- days,
        wd in @weekdays,
        is_map(day) do
      for phase <- @phases,
          {task_key, position} <- Enum.with_index(List.wrap(day[phase])),
          Map.has_key?(tasks, task_key) do
        Repo.insert!(%ScheduleTask{
          kid_id: kid_id,
          weekday: wd,
          phase: phase,
          task_key: task_key,
          position: position
        })
      end

      for act_key <- List.wrap(day["activities"]), Map.has_key?(activities, act_key) do
        Repo.insert!(%ScheduleActivity{kid_id: kid_id, weekday: wd, activity_key: act_key})
      end
    end

    :ok
  end

  defp parse_times(times) do
    with {:ok, morning} <- time_in(times["morningStartsAt"]),
         {:ok, evening} <- time_in(times["eveningStartsAt"]),
         {:ok, night} <- time_in(times["nightStartsAt"]) do
      {:ok, %{morning_starts_at: morning, evening_starts_at: evening, night_starts_at: night}}
    end
  end

  # "HH:MM" aus dem Tablet
  defp time_in(<<h::binary-size(2), ":", m::binary-size(2)>>),
    do: Time.from_iso8601("#{h}:#{m}:00")

  defp time_in(_), do: {:error, :invalid}

  defp time_out(%Time{} = t), do: t |> Time.to_string() |> String.slice(0, 5)
end
