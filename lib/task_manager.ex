defmodule TaskManager do
  @moduledoc """
  TaskManager contains a bunch of useful `Task` utilities.
  """

  require Logger

  def collect(tasks, otps \\ []) when is_list(tasks) do
    constraint = Keyword.get(otps, :constraint, :one_or_more)
    timeout = Keyword.get(otps, :timeout, 5000)

    collect(tasks, constraint, timeout)
  end

  defp collect(tasks, :one_or_more, timeout) do
    tasks_with_results = Task.yield_many(tasks, timeout)

    results =
      tasks_with_results
      |> Enum.map(&resolve_task_or_kill(&1))
      |> Enum.filter(&task_ok?(&1))
      |> Enum.map(&unwrap(&1))

    results
  end

  defp resolve_task_or_kill({task, nil}) do
    _ = Logger.warn("Task timed out, shutting down.")
    _ = Task.shutdown(task, :brutal_kill)

    {:error, :timeout}
  end

  defp resolve_task_or_kill({_task, {:ok, _result} = result}), do: result
  defp resolve_task_or_kill({_task, {:error, _error} = error}), do: error

  defp task_ok?({:ok, _result}), do: true
  defp task_ok?(_), do: false

  defp unwrap({:ok, result}), do: result
end
