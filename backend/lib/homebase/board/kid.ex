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
    timestamps(type: :utc_datetime)
  end

  def changeset(kid, attrs) do
    kid
    |> cast(attrs, [:id, :name, :avatar, :color, :literacy, :can_add_own, :position])
    |> validate_required([:id, :name, :avatar, :color, :literacy, :position])
    |> validate_length(:name, max: 20)
    |> validate_inclusion(:literacy, ~w(icons text))
  end
end
