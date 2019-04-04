defmodule Test.Support.Tasks do
  @moduledoc false

  def generate_async_tasks(items, opts \\ []) when is_list(items) and length(items) > 0 do
    {min_timeout, max_timeout} = opts |> Keyword.get(:timeout_range, {500, 1500})

    items
    |> Enum.map(fn item ->
      timeout = item |> Map.get(:timeout, Enum.random(min_timeout..max_timeout))

      Task.async(fn ->
        :timer.sleep(timeout)
        item
      end)
    end)
  end
end
