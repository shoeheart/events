defmodule Events.CLI do
  import Events.TableFormatter, only: [print_table_for_columns: 2]

  @default_count 4

  @moduledoc """
    Handle command line invocation of Events app to
    display past _n_ events in a github project
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def process(:help) do
    IO.puts("""
    usage:  events <user> <project> [ count | #{@default_count} ]
    """)

    System.halt(0)
  end

  def process({user, project, count}) do
    Events.GithubEvents.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)
    |> print_table_for_columns(["id", "created_at", "type"])
  end

  def last(list, count) do
    list
    |> Enum.take(count)

    # let's not reverse
    # |> Enum.reverse()
  end

  def sort_into_descending_order(list_of_events) do
    list_of_events
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  @doc """
    'argv' can be -h -or --help, which returns :help.

    Otherwise it is github user name, project name, and
    (optionally) number of events to retrieve.

    Return a tuple of '{ user, project, count }', or ':help' if help was given.
  """
  def parse_args(argv) do
    OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end
end
