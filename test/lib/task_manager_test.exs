defmodule Test.TaskManager do
  use ExUnit.Case

  import Test.Support.Tasks, only: [generate_async_tasks: 1]

  # doctest Example

  setup do
    tasks = 1..3 |> Enum.map(fn id -> %{id: id} end)

    {:ok, %{tasks: tasks}}
  end

  test "collect/2 yields one or more unwrapped results with :only_success strategy" do
    tasks =
      1..3
      |> Enum.map(fn index -> %{timeout: 100 * index, id: index} end)
      |> generate_async_tasks()

    results = TaskManager.collect(tasks, result_type: :only_success, timeout: 250)

    assert {:ok, [%{id: 1, timeout: 100}, %{id: 2, timeout: 200}]} == results
  end

  test "collect/2 returns error if no result has been collected within timeout with :only_success strategy" do
    tasks =
      1..3
      |> Enum.map(fn index -> %{timeout: 1000 * index, id: index} end)
      |> generate_async_tasks()

    results = TaskManager.collect(tasks, result_type: :only_success, timeout: 500)

    assert {:error, :no_results} == results
  end

  test "collect/2 yields all results with no strategy" do
    tasks =
      1..3
      |> Enum.map(fn index -> %{timeout: 100 * index, id: index} end)
      |> generate_async_tasks()

    results = TaskManager.collect(tasks, timeout: 250)

    assert {:ok, [ok: %{id: 1, timeout: 100}, ok: %{id: 2, timeout: 200}, error: :timeout]} ==
             results
  end
end
