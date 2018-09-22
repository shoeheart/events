defmodule CliTest do
  use ExUnit.Case
  doctest Events

  import Events.CLI, only: [parse_args: 1, sort_into_descending_order: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "count is defaulted if two values given" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort events by descending order" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
    result = sort_into_descending_order(fake_created_at_list(["c", "a", "b"]))
    events = for event <- result, do: Map.get(event, "created_at")
    assert events == ~w{ c b a }
  end

  defp fake_created_at_list(values) do
    for value <- values,
        do: %{"created_at" => value, "other_data" => "xxx"}
  end
end
