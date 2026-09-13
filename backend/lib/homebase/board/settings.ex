defmodule Homebase.Board.Settings do
  @moduledoc "Umschaltzeiten und Feiersound. Genau eine Zeile."
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :morning_starts_at, :time
    field :afternoon_starts_at, :time
    field :evening_starts_at, :time
    field :night_starts_at, :time
    field :sound, :boolean, default: true
    timestamps(type: :utc_datetime)
  end

  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [
      :morning_starts_at,
      :afternoon_starts_at,
      :evening_starts_at,
      :night_starts_at,
      :sound
    ])
    |> validate_required([
      :morning_starts_at,
      :afternoon_starts_at,
      :evening_starts_at,
      :night_starts_at,
      :sound
    ])
  end
end
