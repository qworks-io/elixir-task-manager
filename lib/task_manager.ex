defmodule TaskManager do
  @moduledoc """
  TaskManager contains a bunch of useful `Task` utilities.
  """

  require Logger

  def collect(tasks, otps \\ []) when is_list(tasks) and length(tasks) > 0 do
    constraint = Keyword.get(otps, :constraint)
    remove_error_results? = Keyword.get(otps, :remove_error_results, false)
    unwrap? = Keyword.get(otps, :unwrap, false)
    timeout = Keyword.get(otps, :timeout, 5000)

    result = collect(tasks, constraint, timeout)

    result
    |> post_process(:remove_error_results, remove_error_results?)
    |> post_process(:unwrap, unwrap?)
  end

  defp collect(tasks, :at_least_one_success, timeout) do
    results = collect_results_or_kill(tasks, timeout)

    has_success_results? = results |> Enum.any?(&task_resolved_ok?(&1))

    case has_success_results? do
      true -> {:ok, results}
      _ -> {:error, :no_results}
    end
  end

  defp collect(tasks, _, timeout) do
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

  defp post_process({:ok, results}, :remove_error_results, true) do
    results |> Enum.filter(&task_resolved_ok?(&1))
  end

  defp post_process({:ok, results}, :unwrap, true) do
    results |> Enum.map(&unwrap_result(&1))
  end

  defp post_process(result, _type, _value), do: result

  defp unwrap_result({:ok, result}), do: result

  defp task_resolved_ok?({:ok, _result}), do: true
  defp task_resolved_ok?(_), do: false
end
