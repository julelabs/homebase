defmodule Homebase.Board.Config do
  @moduledoc "Die Board-Konfiguration als JSON-Dokument. Es existiert genau eine Zeile."
  use Ecto.Schema
  import Ecto.Changeset

  schema "configs" do
    field :data, :map
    timestamps(type: :utc_datetime)
  end

  @required_keys ~w(kids tasks schedule times)

  def changeset(config, data) do
    config
    |> change(data: data)
    |> validate_change(:data, fn :data, data ->
      if is_map(data) and Enum.all?(@required_keys, &Map.has_key?(data, &1)),
        do: [],
        else: [data: "muss kids, tasks, schedule und times enthalten"]
    end)
  end
end
