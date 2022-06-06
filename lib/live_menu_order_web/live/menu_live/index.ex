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
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "add_to_cart", value)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", value, socket) do
    CartState.remove(value)
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "remove_from_cart", value)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "add_to_cart", payload: payload}, socket) do
    state = socket.assigns.cart

    new_cart =
      case Map.has_key?(state, payload["menu_id"]) do
        true ->
          {_old, new_state} =
            get_and_update_in(state, [payload["menu_id"], "count"], &{&1, &1 + 1})

          new_state

        false ->
          temp = %{payload["menu_id"] => Map.merge(payload, %{"count" => 1})}
          Map.merge(state, temp)
      end

    {:noreply,
     socket
     |> assign(:cart, new_cart)}
  end

  @impl true
  def handle_info(%{event: "remove_from_cart", payload: payload}, socket) do
    state = socket.assigns.cart

    {_old, new_state} = get_and_update_in(state, [payload["menu_id"], "count"], &{&1, &1 - 1})
    count = get_in(new_state, [payload["menu_id"], "count"])

    new_cart =
      case count do
        0 -> Map.delete(new_state, payload["menu_id"])
        _ -> new_state
      end

    {:noreply,
     socket
     |> assign(:cart, new_cart)}
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
