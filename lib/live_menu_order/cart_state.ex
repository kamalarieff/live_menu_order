defmodule CartState do
  use Agent

  def start_link(%{initial_value: initial_value, name: name}) do
    Agent.start_link(fn -> initial_value end, name: name)
  end

  def value(name) do
    Agent.get(name, & &1)
  end

  def add(name, value) do
    Agent.update(name, fn state ->
      case Map.has_key?(state, value["menu_id"]) do
        true ->
          new_state =
            update_in(state, [value["menu_id"]], fn current_value ->
              new_count = current_value["count"] + 1

              Map.merge(current_value, %{
                "count" => new_count,
                "total_price" => new_count * String.to_float(current_value["menu_price"])
              })
            end)

          new_state

        false ->
          temp = %{
            value["menu_id"] =>
              Map.merge(value, %{
                "count" => 1,
                "total_price" => String.to_float(value["menu_price"])
              })
          }

          Map.merge(state, temp)
      end
    end)
  end

  def remove(name, value) do
    Agent.update(name, fn state ->
      new_state =
        update_in(state, [value["menu_id"]], fn current_value ->
          new_count = current_value["count"] - 1

          Map.merge(current_value, %{
            "count" => new_count,
            "total_price" => new_count * String.to_float(current_value["menu_price"])
          })
        end)

      count = get_in(new_state, [value["menu_id"], "count"])

      case count do
        0 -> Map.delete(new_state, value["menu_id"])
        _ -> new_state
      end
    end)
  end

  def clear(name) do
    Agent.update(name, fn _ -> %{} end)
  end
end

defmodule LastAddedState do
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> nil end, name: name)
  end

  def value(name) do
    Agent.get(name, & &1)
  end

  def update(name, value) do
    Agent.update(name, fn _ -> value["menu_name"] end)
  end

  def clear(name) do
    Agent.update(name, fn _ -> nil end)
  end
end
