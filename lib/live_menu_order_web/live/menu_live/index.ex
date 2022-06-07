defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias LiveMenuOrder.Orders
  alias LiveMenuOrder.Orders.Order
  alias CartState
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe("orders")
    cart = CartState.value()
    {:ok, assign(socket, menus: list_menus(), cart: cart, total: 0)}
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
  def handle_event("save_order", %{"order" => order}, socket) do
    Orders.create_order(%{order: order, total: socket.assigns.total})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "update_state", payload: state}, socket) do
    total =
      for {_id, item} <- state, reduce: 0 do
        acc ->
          item["total_price"] + acc
      end

    {:noreply,
     socket
     |> assign(:cart, state)
     |> assign(:total, total)}
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

  def remove(value) do
    Agent.update(__MODULE__, fn state ->
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
end
