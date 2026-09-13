defmodule Homebase.Board do
  @moduledoc """
  Zugriff auf die drei Datensätze des Flur-Tablets: Config, Tageszustand, Nachricht.
  Die Config liegt in eigenen Tabellen, siehe `Homebase.Board.Config`.

  Der Tageszustand hat dieselbe Form wie im Prototyp:

      %{"date" => "2026-09-13",
        "checked" => %{"k1" => %{"brotbox" => true}},
        "own" => %{"k1" => [%{"id" => "o1", "phase" => "morning", "icon" => "star", "label" => "Buch"}]}}
  """

  import Ecto.Query
  alias Homebase.Repo
  alias Homebase.Board.{Check, Config, Message, OwnTask}

  @phases ~w(morning afternoon evening)

  ## Config

  @doc "Die Board-Config in Tablet-Form oder nil, solange die Seeds nicht eingespielt sind."
  defdelegate get_config, to: Config, as: :load

  @doc "Ersetzt die komplette Config (Kinder, Aufgaben, Aktivitäten, Wochenplan, Zeiten)."
  defdelegate put_config(data), to: Config, as: :replace

  ## Tageszustand

  @doc "Haken und eigene Aufgaben eines Tages."
  def get_day(%Date{} = date) do
    checked =
      from(c in Check, where: c.date == ^date, select: {c.kid_id, c.task_key})
      |> Repo.all()
      |> Enum.reduce(%{}, fn {kid, key}, acc ->
        Map.update(acc, kid, %{key => true}, &Map.put(&1, key, true))
      end)

    own =
      from(o in OwnTask, where: o.date == ^date, order_by: o.inserted_at, select: o)
      |> Repo.all()
      |> Enum.group_by(& &1.kid_id, &own_task_to_map/1)

    %{"date" => Date.to_iso8601(date), "checked" => checked, "own" => own}
  end

  @doc """
  Ersetzt den Tageszustand komplett durch die übergebenen Haken und eigenen Aufgaben.
  Wiederholtes Senden desselben Zustands ist unschädlich.
  """
  def put_day(%Date{} = date, %{"checked" => checked, "own" => own})
      when is_map(checked) and is_map(own) do
    with {:ok, check_rows} <- check_rows(date, checked),
         {:ok, own_rows} <- own_rows(date, own) do
      Repo.transaction(fn ->
        Repo.delete_all(from c in Check, where: c.date == ^date)
        Repo.delete_all(from o in OwnTask, where: o.date == ^date)
        if check_rows != [], do: Repo.insert_all(Check, check_rows)
        if own_rows != [], do: Repo.insert_all(OwnTask, own_rows)
      end)

      {:ok, get_day(date)}
    end
  end

  def put_day(_date, _params), do: {:error, :invalid}

  defp check_rows(date, checked) do
    now = now()

    rows =
      for {kid, keys} <- checked, is_map(keys), {key, true} <- keys do
        %{date: date, kid_id: kid, task_key: key, inserted_at: now}
      end

    if Enum.all?(rows, &(is_binary(&1.kid_id) and is_binary(&1.task_key))),
      do: {:ok, rows},
      else: {:error, :invalid}
  end

  defp own_rows(date, own) do
    now = now()

    rows =
      for {kid, list} <- own, is_list(list), item <- list do
        %{
          id: item["id"],
          date: date,
          kid_id: kid,
          phase: item["phase"],
          icon: item["icon"],
          label: item["label"],
          inserted_at: now
        }
      end

    valid? =
      Enum.all?(rows, fn r ->
        is_binary(r.id) and is_binary(r.kid_id) and r.phase in @phases and
          is_binary(r.icon) and is_binary(r.label) and String.length(r.label) <= 40
      end)

    if valid?, do: {:ok, rows}, else: {:error, :invalid}
  end

  defp own_task_to_map(%OwnTask{} = o) do
    %{"id" => o.id, "phase" => o.phase, "icon" => o.icon, "label" => o.label}
  end

  ## Nachricht

  @doc "Die Nachricht eines Tages oder nil."
  def get_message(%Date{} = date) do
    case Repo.get_by(Message, date: date) do
      nil -> nil
      msg -> message_to_map(msg)
    end
  end

  @doc "Setzt die Nachricht eines Tages. Leerer Text löscht sie."
  def put_message(%Date{} = date, text) when is_binary(text) do
    text = text |> String.replace(~r/\s+/, " ") |> String.trim()

    if text == "" do
      Repo.delete_all(from m in Message, where: m.date == ^date)
      {:ok, %{"date" => Date.to_iso8601(date), "text" => ""}}
    else
      existing = Repo.get_by(Message, date: date) || %Message{}

      case Repo.insert_or_update(Message.changeset(existing, %{date: date, text: text})) do
        {:ok, msg} -> {:ok, message_to_map(msg)}
        {:error, _} -> {:error, :invalid}
      end
    end
  end

  def put_message(_date, _text), do: {:error, :invalid}

  defp message_to_map(%Message{date: date, text: text}) do
    %{"date" => Date.to_iso8601(date), "text" => text}
  end

  defp now, do: DateTime.utc_now(:second)
end
