defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias LiveMenuOrder.Orders
  alias CartState
  alias Phoenix.LiveView.JS

  @process_name "table:order"
  @cart_name {:via, Registry, {LiveMenuOrder.Registry, @process_name}}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe("orders")

    DynamicSupervisor.start_child(
      LiveMenuOrder.DynamicSupervisor,
      {CartState, %{initial_value: %{}, name: @cart_name}}
    )

    cart = CartState.value(@cart_name)

    total =
      for {_id, item} <- cart, reduce: 0 do
        acc ->
          item["total_price"] + acc
      end

    {:ok, assign(socket, menus: list_menus(), cart: cart, total: total)}
  end

  @impl true
  def handle_event("add", value, socket) do
    CartState.add(@cart_name, value)
    cart_state = CartState.value(@cart_name)
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "update_state", cart_state)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", value, socket) do
    CartState.remove(@cart_name, value)
    cart_state = CartState.value(@cart_name)
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "update_state", cart_state)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_order", %{"order" => order}, socket) do
    {:ok, order} = Orders.create_order(%{order: order, total: socket.assigns.total})
    [{pid, _}] = Registry.lookup(LiveMenuOrder.Registry, @process_name)
    DynamicSupervisor.terminate_child(LiveMenuOrder.DynamicSupervisor, pid)

    {:noreply,
     socket
     |> assign(cart: [])
     |> assign(total: 0)
     |> push_redirect(to: Routes.order_show_path(socket, :show, order))
    }
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
end
