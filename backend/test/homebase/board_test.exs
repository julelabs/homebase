defmodule Homebase.BoardTest do
  use Homebase.DataCase, async: true

  alias Homebase.Board

  @date ~D[2026-09-13]

  @config %{
    "kids" => [
      %{
        "id" => "k1",
        "name" => "Anna",
        "avatar" => "fox",
        "color" => "salbei",
        "literacy" => "icons",
        "canAddOwn" => true
      },
      %{
        "id" => "k2",
        "name" => "Ben",
        "avatar" => "dragon",
        "color" => "staubblau",
        "literacy" => "text",
        "canAddOwn" => false
      }
    ],
    "tasks" => %{
      "zaehne" => %{"label" => "Zähne putzen", "short" => "Zähne", "icon" => "toothbrush"},
      "brotbox" => %{
        "label" => "Brotbox in die Küche",
        "short" => "Brotbox",
        "icon" => "lunchbox"
      },
      "schwimm_mit" => %{
        "label" => "Schwimmsachen mitnehmen",
        "short" => "Schwimmen",
        "icon" => "swim"
      }
    },
    "activities" => %{
      "swim" => %{"label" => "Schwimmen", "morning" => "schwimm_mit", "eveningBefore" => nil}
    },
    "schedule" => %{
      "k1" => %{
        "mon" => %{
          "morning" => ["zaehne", "brotbox"],
          "afternoon" => ["brotbox"],
          "evening" => ["zaehne"],
          "activities" => ["swim"]
        }
      },
      "k2" => %{
        "sat" => %{
          "morning" => ["brotbox"],
          "afternoon" => [],
          "evening" => [],
          "activities" => []
        }
      }
    },
    "times" => %{
      "morningStartsAt" => "06:00",
      "afternoonStartsAt" => "12:00",
      "eveningStartsAt" => "17:00",
      "nightStartsAt" => "19:00"
    },
    "sound" => false
  }

  describe "config" do
    test "is nil until seeded" do
      assert Board.get_config() == nil
    end

    test "round trips kids, tasks, activities, schedule, times and sound" do
      assert {:ok, config} = Board.put_config(@config)
      assert config == Board.get_config()

      assert Enum.map(config["kids"], & &1["id"]) == ["k1", "k2"]
      assert Enum.at(config["kids"], 1)["canAddOwn"] == false
      assert config["activities"]["swim"]["morning"] == "schwimm_mit"

      assert config["schedule"]["k1"]["mon"] == %{
               "morning" => ["zaehne", "brotbox"],
               "afternoon" => ["brotbox"],
               "evening" => ["zaehne"],
               "activities" => ["swim"]
             }

      assert config["schedule"]["k2"]["mon"] == %{
               "morning" => [],
               "afternoon" => [],
               "evening" => [],
               "activities" => []
             }

      assert config["times"] == @config["times"]
      assert config["sound"] == false
    end

    test "tasks keep their position across writes, new tasks are appended" do
      {:ok, _} = Board.put_config(@config)
      first_order = Board.get_config()["tasks"] |> Enum.map(fn {k, _} -> k end)

      tasks =
        Map.put(@config["tasks"], "aaa_neu", %{
          "label" => "Neu",
          "short" => "Neu",
          "icon" => "star"
        })

      {:ok, config} = Board.put_config(Map.put(@config, "tasks", tasks))

      assert Enum.map(config["tasks"], fn {k, _} -> k end) == first_order ++ ["aaa_neu"]
    end

    test "tasks encode as an ordered JSON object" do
      {:ok, config} = Board.put_config(@config)
      json = Jason.encode!(config["tasks"])
      keys = Regex.scan(~r/"(zaehne|brotbox|schwimm_mit)":\{/, json) |> Enum.map(&Enum.at(&1, 1))
      assert keys == Enum.map(config["tasks"], fn {k, _} -> k end)
    end

    test "an ordered object sets task positions explicitly" do
      tasks =
        Jason.OrderedObject.new(
          Enum.map(~w(schwimm_mit zaehne brotbox), &{&1, @config["tasks"][&1]})
        )

      {:ok, config} = Board.put_config(Map.put(@config, "tasks", tasks))
      assert Enum.map(config["tasks"], fn {k, _} -> k end) == ~w(schwimm_mit zaehne brotbox)
    end

    test "removing a task removes it from the schedule" do
      {:ok, _} = Board.put_config(@config)
      tasks = Map.delete(@config["tasks"], "zaehne")
      {:ok, config} = Board.put_config(Map.put(@config, "tasks", tasks))
      assert config["schedule"]["k1"]["mon"]["morning"] == ["brotbox"]
      assert config["schedule"]["k1"]["mon"]["evening"] == []
    end

    test "deleting a task an activity refers to clears the reference" do
      {:ok, _} = Board.put_config(@config)
      tasks = Map.delete(@config["tasks"], "schwimm_mit")
      {:ok, config} = Board.put_config(Map.put(@config, "tasks", tasks))
      assert config["activities"]["swim"]["morning"] == nil
    end

    test "an empty kid name is allowed while the parent retypes it" do
      kids = List.update_at(@config["kids"], 0, &Map.put(&1, "name", ""))
      {:ok, config} = Board.put_config(Map.put(@config, "kids", kids))
      assert hd(config["kids"])["name"] == ""
    end

    test "rejects incomplete or malformed configs" do
      assert {:error, :invalid} = Board.put_config(%{"kids" => []})

      assert {:error, :invalid} =
               Board.put_config(Map.put(@config, "times", %{"morningStartsAt" => "früh"}))

      bad_kid = %{
        "id" => "k3",
        "name" => "X",
        "avatar" => "fox",
        "color" => "sand",
        "literacy" => "pictures"
      }

      assert {:error, :invalid} = Board.put_config(Map.put(@config, "kids", [bad_kid]))
      long_key = String.duplicate("x", 300)

      long_tasks =
        Map.put(@config["tasks"], long_key, %{"label" => "L", "short" => "L", "icon" => "star"})

      assert {:error, :invalid} = Board.put_config(Map.put(@config, "tasks", long_tasks))
      assert Board.get_config() == nil
    end
  end

  describe "day" do
    test "empty day has no checks and no own tasks" do
      assert Board.get_day(@date) == %{"date" => "2026-09-13", "checked" => %{}, "own" => %{}}
    end

    test "put_day replaces the whole day and is idempotent" do
      day = %{
        "checked" => %{"k1" => %{"brotbox" => true, "schuhe" => true}, "k2" => %{}},
        "own" => %{
          "k2" => [%{"id" => "o1", "phase" => "morning", "icon" => "star", "label" => "Buch"}]
        }
      }

      assert {:ok, saved} = Board.put_day(@date, day)
      assert {:ok, ^saved} = Board.put_day(@date, day)
      assert saved["checked"] == %{"k1" => %{"brotbox" => true, "schuhe" => true}}
      assert saved["own"] == day["own"]

      # Ein Haken weg, eigene Aufgabe weg
      {:ok, next} =
        Board.put_day(@date, %{"checked" => %{"k1" => %{"schuhe" => true}}, "own" => %{}})

      assert next["checked"] == %{"k1" => %{"schuhe" => true}}
      assert next["own"] == %{}
    end

    test "days do not leak into each other" do
      {:ok, _} =
        Board.put_day(@date, %{"checked" => %{"k1" => %{"brotbox" => true}}, "own" => %{}})

      assert Board.get_day(~D[2026-09-14])["checked"] == %{}
    end

    test "rejects malformed own tasks" do
      bad = %{"checked" => %{}, "own" => %{"k1" => [%{"id" => "x", "phase" => "noon"}]}}
      assert {:error, :invalid} = Board.put_day(@date, bad)
    end
  end

  describe "message" do
    test "set, overwrite and clear" do
      assert Board.get_message(@date) == nil

      {:ok, m} = Board.put_message(@date, "  Papa holt   euch ab ")
      assert m == %{"date" => "2026-09-13", "text" => "Papa holt euch ab"}

      {:ok, _} = Board.put_message(@date, "Oma kommt")
      assert Board.get_message(@date)["text"] == "Oma kommt"

      {:ok, _} = Board.put_message(@date, "")
      assert Board.get_message(@date) == nil
    end
  end
end
