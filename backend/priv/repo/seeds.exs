# Seeds: die Board-Config aus dem Prototyp (Kinder, Aufgaben, Aktivitäten, Wochenplan, Zeiten).
# Wird nur eingespielt, wenn noch keine Config existiert, damit Änderungen aus dem
# Elternbereich bei einem erneuten Lauf nicht überschrieben werden.
#
#     mix run priv/repo/seeds.exs      # lokal, auf Fly automatisch bei jedem Deploy (Release.setup)
#
# Beispieldaten für die lokale Entwicklung liegen in dev_seeds.exs.

alias Homebase.Board

school_morning = ~w(zaehne)
school_morning_k2 = ~w(zaehne ranzen)
school_afternoon = ~w(brotbox flasche schuhe jacke)
school_afternoon_k2 = school_afternoon ++ ["hausaufgaben"]
evening = ~w(tisch_ab zaehne duschen schlafanzug)
weekend_morning = ~w(zaehne zimmer)
weekend_afternoon = []

day = fn morning, afternoon, evening, activities ->
  %{
    "morning" => morning,
    "afternoon" => afternoon,
    "evening" => evening,
    "activities" => activities
  }
end

task = fn label, short, icon -> %{"label" => label, "short" => short, "icon" => icon} end

default_config = %{
  "kids" => [
    %{
      "id" => "k1",
      "name" => "Kind 1",
      "avatar" => "fox",
      "color" => "salbei",
      "literacy" => "icons",
      "canAddOwn" => true
    },
    %{
      "id" => "k2",
      "name" => "Kind 2",
      "avatar" => "dragon",
      "color" => "staubblau",
      "literacy" => "text",
      "canAddOwn" => true
    }
  ],
  # Geordnet, damit die Positionen der Reihenfolge im Prototyp entsprechen.
  "tasks" =>
    Jason.OrderedObject.new([
      {"brotbox", task.("Brotbox in die Küche", "Brotbox", "lunchbox")},
      {"flasche", task.("Trinkflasche in die Küche", "Flasche", "bottle")},
      {"schuhe", task.("Schuhe wegräumen", "Schuhe", "shoes")},
      {"jacke", task.("Jacke aufhängen", "Jacke", "jacket")},
      {"zaehne", task.("Zähne putzen", "Zähne", "toothbrush")},
      {"ranzen", task.("Schulranzen packen", "Ranzen", "backpack")},
      {"hausaufgaben", task.("Hausaufgaben", "Hausaufgaben", "homework")},
      {"tisch", task.("Tisch decken", "Tisch decken", "table")},
      {"tisch_ab", task.("Tisch abräumen", "Tisch", "table")},
      {"duschen", task.("Duschen oder baden", "Duschen", "shower")},
      {"zimmer", task.("Zimmer aufräumen", "Zimmer", "room")},
      {"schlafanzug", task.("Schlafanzug anziehen", "Schlafanzug", "pajamas")},
      {"schwimm_packen", task.("Schwimmsachen packen", "Schwimmen packen", "swim")},
      {"schwimm_mit", task.("Schwimmsachen mitnehmen", "Schwimmen", "swim")},
      {"sport_packen", task.("Sportsachen packen", "Sport packen", "sport")},
      {"sport_mit", task.("Sportsachen mitnehmen", "Sport", "sport")}
    ]),
  "activities" =>
    Jason.OrderedObject.new([
      {"swim",
       %{"label" => "Schwimmen", "morning" => "schwimm_mit", "eveningBefore" => "schwimm_packen"}},
      {"sport",
       %{"label" => "Sport", "morning" => "sport_mit", "eveningBefore" => "sport_packen"}}
    ]),
  "schedule" => %{
    "k1" => %{
      "mon" => day.(school_morning, school_afternoon, evening, []),
      "tue" => day.(school_morning, school_afternoon, evening, ["swim"]),
      "wed" => day.(school_morning, school_afternoon, evening, []),
      "thu" => day.(school_morning, school_afternoon, evening, []),
      "fri" => day.(school_morning, school_afternoon, evening, []),
      "sat" => day.(weekend_morning, weekend_afternoon, evening, []),
      "sun" => day.(weekend_morning, weekend_afternoon, evening, [])
    },
    "k2" => %{
      "mon" => day.(school_morning_k2, school_afternoon_k2, evening, []),
      "tue" => day.(school_morning_k2, school_afternoon_k2, evening, []),
      "wed" => day.(school_morning_k2, school_afternoon_k2, evening, []),
      "thu" => day.(school_morning_k2, school_afternoon_k2, evening, ["sport"]),
      "fri" => day.(school_morning_k2, school_afternoon_k2, evening, []),
      "sat" => day.(weekend_morning, weekend_afternoon, evening, []),
      "sun" => day.(weekend_morning, weekend_afternoon, evening, [])
    }
  },
  "times" => %{
    "morningStartsAt" => "06:00",
    "afternoonStartsAt" => "12:00",
    "eveningStartsAt" => "17:00",
    "nightStartsAt" => "19:00"
  },
  "sound" => true
}

if Homebase.Repo.exists?(Homebase.Board.Settings) do
  IO.puts("Config vorhanden, Seeds nicht überschrieben.")
else
  {:ok, _} = Board.put_config(default_config)
  IO.puts("Config aus den Prototyp-Defaults eingespielt.")
end
