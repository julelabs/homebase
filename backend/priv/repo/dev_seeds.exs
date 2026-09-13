# Beispieldaten für die lokale Entwicklung: Nachricht, Haken und eine eigene Aufgabe für heute.
# Läuft über `mix ecto.setup` und `mix ecto.reset`, nie im Release.

alias Homebase.Board

today = Date.utc_today()
{:ok, _} = Board.put_message(today, "Papa holt euch heute ab")

{:ok, _} =
  Board.put_day(today, %{
    # Haken-Schlüssel sind "phase:aufgabe", wie das Tablet sie schreibt
    "checked" => %{
      "k1" => %{"morning:zaehne" => true, "evening:zaehne" => true},
      "k2" => %{"morning:brotbox" => true, "morning:flasche" => true}
    },
    "own" => %{
      "k2" => [
        %{
          "id" => "seed-1",
          "phase" => "morning",
          "icon" => "library",
          "label" => "Buch mitnehmen"
        }
      ]
    }
  })

IO.puts("Beispieldaten für #{today} eingespielt.")
