defmodule TaskManager do
  @moduledoc """
  TaskManager contains a bunch of useful `Task` utilities.
  """

  require Logger

  def collect(tasks, otps \\ []) when is_list(tasks) and length(tasks) > 0 do
    result_type = Keyword.get(otps, :result_type)
    timeout = Keyword.get(otps, :timeout, 5000)

    results = collect(tasks, result_type, timeout)

    results
    |> post_process(result_type)
  end

  defp collect(tasks, :only_success, timeout) do
    results = collect_results_or_kill(tasks, timeout)

    has_success_results? = results |> Enum.any?(&task_resolved_ok?(&1))

    case has_success_results? do
      true -> {:ok, results}
      _ -> {:error, :no_results}
    end
  end

  defp collect(tasks, _result_type, timeout) do
    results = collect_results_or_kill(tasks, timeout)
    {:ok, results}
  end

  defp collect_results_or_kill(tasks, timeout) do
    tasks_with_results = Task.yield_many(tasks, timeout)
    tasks_with_results |> Enum.map(&collect_result_or_kill(&1))
  end

  defp collect_result_or_kill({task, nil}) do
    _ = Logger.warn("Task timed out, shutting down.")
    _ = Task.shutdown(task, :brutal_kill)

    {:error, :timeout}
  end

  defp collect_result_or_kill({_task, result}), do: result

  defp post_process({:ok, results}, :only_success) do
    results = results |> Enum.filter(&task_resolved_ok?(&1)) |> Enum.map(&unwrap_result(&1))
    {:ok, results}
  end

  defp post_process(result, _result_type), do: result

  defp unwrap_result({:ok, result}), do: result

  defp task_resolved_ok?({:ok, _result}), do: true
  defp task_resolved_ok?(_), do: false
end
