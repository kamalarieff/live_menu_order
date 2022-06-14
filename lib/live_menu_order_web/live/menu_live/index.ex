defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias LiveMenuOrder.Orders
  alias LiveMenuOrder.Orders.Order
  alias LiveMenuOrder.Tables
  alias LiveMenuOrder.Tables.Table
  alias LiveMenuOrder.DynamicSupervisor
  alias CartState
  alias Phoenix.LiveView.JS

  @impl true
  def mount(%{"table_id" => table_id}, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe(table_topic(table_id))

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"table_id" => table_id}, _session, socket) do
    table = %Table{id: table_id}
    order = Tables.get_single_order_by_table(table_id)

    order =
      case order do
        nil -> %Order{table_id: String.to_integer(table_id)}
        _ -> order
      end

    cart_name = via_tuple(table_id)

    DynamicSupervisor.start_child({CartState, %{initial_value: %{}, name: cart_name}})

    cart = CartState.value(cart_name)

    total =
      for {_id, item} <- order.order, reduce: 0 do
        acc ->
          item["total_price"] + acc
      end

    total =
      for {_id, item} <- cart, reduce: total do
        acc ->
          item["total_price"] + acc
      end

    {:noreply,
     assign(socket, menus: list_menus(), cart: cart, total: total, table: table, order: order)}
  end

  @impl true
  def handle_event("add", value, socket) do
    cart_name = via_tuple(socket.assigns.table.id)
    CartState.add(cart_name, value)
    cart_state = CartState.value(cart_name)

    LiveMenuOrderWeb.Endpoint.broadcast(
      table_topic(socket.assigns.table.id),
      "update_state",
      cart_state
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", value, socket) do
    cart_name = via_tuple(socket.assigns.table.id)
    CartState.remove(cart_name, value)
    cart_state = CartState.value(cart_name)

    LiveMenuOrderWeb.Endpoint.broadcast(
      table_topic(socket.assigns.table.id),
      "update_state",
      cart_state
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_order", %{"order" => order}, socket) do
    {:ok, order} =
      case socket.assigns.order.id do
        nil ->
          Orders.create_order(%{
            order: order,
            total: socket.assigns.total,
            table_id: socket.assigns.table.id
          })

        _ ->
          temp =
            Map.merge(socket.assigns.order.order, order, fn _k, v1, v2 ->
              Map.merge(v1, v2, fn key, vv1, vv2 ->
                case key do
                  "count" -> vv1 + vv2
                  "total_price" -> vv1 + vv2
                  _ -> vv1
                end
              end)
            end)

          Orders.update_order(socket.assigns.order, %{
            order: temp,
            total: socket.assigns.total,
            table_id: socket.assigns.table.id
          })
      end

    LiveMenuOrderWeb.Endpoint.broadcast(table_topic(socket.assigns.table.id), "save_order", nil)

    cart_name = via_tuple(socket.assigns.table.id)
    CartState.clear(cart_name)

    {:noreply,
     socket
     |> assign(cart: [])
     |> assign(total: 0)
     |> push_redirect(to: Routes.order_show_path(socket, :show, order.table_id))}
  end

  @impl true
  def handle_event("click_order", %{"table_id" => table_id}, socket) do
    {:noreply, socket |> push_redirect(to: Routes.order_show_path(socket, :show, table_id))}
  end

  @impl true
  def handle_info(%{event: "update_state", payload: state}, socket) do
    total =
      for {_id, item} <- socket.assigns.order.order, reduce: 0 do
        acc ->
          item["total_price"] + acc
      end

    total =
      for {_id, item} <- state, reduce: total do
        acc ->
          item["total_price"] + acc
      end

    {:noreply,
     socket
     |> assign(:cart, state)
     |> assign(:total, total)}
  end

  @impl true
  def handle_info(%{event: "save_order"}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Order sent.")
     |> push_patch(to: Routes.menu_index_path(socket, :index, socket.assigns.table.id))}
  end

  @impl true
  def handle_info(%{event: "kick"}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Order closed.")
     |> push_patch(to: Routes.menu_index_path(socket, :index, socket.assigns.table.id))}
  end

  defp list_menus do
    Menus.list_menus()
  end

  defp process_name(table_id) do
    "table:" <> table_id
  end

  defp table_topic(table_id) do
    "table:" <> table_id
  end

  defp via_tuple(table_id) do
    {:via, Registry, {LiveMenuOrder.Registry, process_name(table_id)}}
  end
end
