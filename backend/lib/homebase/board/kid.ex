defmodule Homebase.Board.Kid do
  @moduledoc "Ein Kind mit eigener Spalte auf dem Board."
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "kids" do
    field :name, :string
    field :avatar, :string
    field :color, :string
    # "icons" für Lesestufe Icon-Tiles, "text" für Textzeilen
    field :literacy, :string
    field :can_add_own, :boolean, default: true
    field :position, :integer
  end

  # Der Name darf leer sein (Feld am Tablet gerade geleert), position setzt der Server.
  def changeset(kid, attrs) do
    kid
    |> cast(attrs, [:id, :name, :avatar, :color, :literacy, :can_add_own], empty_values: [])
    |> validate_required([:id, :avatar, :color, :literacy])
    |> validate_length(:name, max: 20)
    |> validate_length(:id, max: 40)
    |> validate_length(:avatar, max: 40)
    |> validate_length(:color, max: 40)
    |> validate_inclusion(:literacy, ~w(icons text))
  end
end
