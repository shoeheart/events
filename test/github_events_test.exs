defmodule GithubEventsTest do
  use ExUnit.Case
  doctest Events

  import Events.GithubEvents, only: [issues_url: 2, handle_response: 1]

  test "url properly constructed" do
    assert issues_url("user", "project") == "https://api.github.com/repos/user/project/events"
  end

  test "success response handled" do
    assert handle_response({:dont_care, %{status_code: 200, body: '{"a": 1}'}}) ==
             {:ok, %{"a" => 1}}
  end

  test "error response handled" do
    assert handle_response({:dont_care, %{status_code: 300, body: '{"a": 1}'}}) ==
             {:error, %{"a" => 1}}
  end
end
