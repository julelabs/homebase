# Beispieldaten für die lokale Entwicklung: eine Nachricht, ein paar Haken und
# eine eigene Aufgabe für heute. Mehrfaches Ausführen ist unschädlich.
#
#     mix run priv/repo/seeds.exs
#
# Die Config legt das Tablet beim ersten Laden selbst an (Defaults in src/index.html).

alias Homebase.Board

today = Date.utc_today()

{:ok, _} = Board.put_message(today, "Papa holt euch heute ab")

{:ok, _} =
  Board.put_day(today, %{
    "checked" => %{"k1" => %{"brotbox" => true}, "k2" => %{"brotbox" => true, "flasche" => true}},
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

IO.puts("Seeds für #{today} eingespielt.")
