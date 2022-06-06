defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias CartState

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe("orders")
    cart = CartState.value()
    {:ok, assign(socket, menus: list_menus(), cart: cart)}
  end

  @impl true
  def handle_event("add", value, socket) do
    CartState.add(value)
    cart_state = CartState.value()
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "update_state", cart_state)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", value, socket) do
    CartState.remove(value)
    cart_state = CartState.value()
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "update_state", cart_state)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "update_state", payload: state}, socket) do
    {:noreply,
     socket
     |> assign(:cart, state)}
  end

  defp list_menus do
    Menus.list_menus()
  end
end

defmodule CartState do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def add(value) do
    Agent.update(__MODULE__, fn state ->
      case Map.has_key?(state, value["menu_id"]) do
        true ->
          {_old, new_state} = get_and_update_in(state, [value["menu_id"], "count"], &{&1, &1 + 1})
          new_state

        false ->
          temp = %{value["menu_id"] => Map.merge(value, %{"count" => 1})}
          Map.merge(state, temp)
      end
    end)
  end

  def remove(value) do
    Agent.update(__MODULE__, fn state ->
      {_old, new_state} = get_and_update_in(state, [value["menu_id"], "count"], &{&1, &1 - 1})
      count = get_in(new_state, [value["menu_id"], "count"])

      case count do
        0 -> Map.delete(new_state, value["menu_id"])
        _ -> new_state
      end
    end)
  end
end
