defmodule Homebase.Board.Message do
  @moduledoc "Die Nachricht der Eltern für einen Tag."
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :date, :date
    field :text, :string
    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:date, :text])
    |> validate_required([:date, :text])
    |> validate_length(:text, max: 80)
    |> unique_constraint(:date)
  end
end
