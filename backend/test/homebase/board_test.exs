defmodule Homebase.BoardTest do
  use Homebase.DataCase, async: true

  alias Homebase.Board

  @date ~D[2026-09-13]

  describe "config" do
    test "is nil until stored, then returned as given" do
      assert Board.get_config() == nil

      data = %{"kids" => [], "tasks" => %{}, "schedule" => %{}, "times" => %{}, "version" => 3}
      assert {:ok, ^data} = Board.put_config(data)
      assert Board.get_config() == data
    end

    test "second put replaces instead of adding a row" do
      base = %{"kids" => [], "tasks" => %{}, "schedule" => %{}, "times" => %{}}
      {:ok, _} = Board.put_config(Map.put(base, "version", 1))
      {:ok, _} = Board.put_config(Map.put(base, "version", 2))
      assert Board.get_config()["version"] == 2
      assert Repo.aggregate(Homebase.Board.Config, :count) == 1
    end

    test "rejects a config without the required keys" do
      assert {:error, :invalid} = Board.put_config(%{"kids" => []})
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
