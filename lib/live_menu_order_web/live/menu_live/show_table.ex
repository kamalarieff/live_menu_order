defmodule LiveMenuOrderWeb.MenuLive.ShowTable do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias LiveMenuOrder.DynamicSupervisor
  alias CartState
  alias LastAddedState

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"table_id" => table_id, "menu_id" => menu_id}, _, socket) do
    cart_name = via_tuple(:table, table_id)
    last_added_name = via_tuple(:last_added, table_id)

    DynamicSupervisor.start_child({CartState, %{initial_value: %{}, name: cart_name}})
    DynamicSupervisor.start_child({LastAddedState, last_added_name})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:menu, Menus.get_menu!(menu_id))
     |> assign(:table_id, table_id)}
  end

  @impl true
  def handle_event("add", value, socket) do
    cart_name = via_tuple(:table, socket.assigns.table_id)
    CartState.add(cart_name, value)
    cart_state = CartState.value(cart_name)

    last_added_name = via_tuple(:last_added, socket.assigns.table_id)
    LastAddedState.update(last_added_name, value)
    last_added = LastAddedState.value(last_added_name)

    LiveMenuOrderWeb.Endpoint.broadcast(
      table_topic(socket.assigns.table_id),
      "update_state",
      %{cart_state: cart_state, last_added: last_added}
    )

    {:noreply,
     socket
     |> put_flash(:info, "Order added.")}
  end

  defp page_title(:show), do: "Show Menu"

  defp table_topic(table_id) do
    "table:" <> table_id
  end

  defp via_tuple(:table, table_id) do
    {:via, Registry, {LiveMenuOrder.Registry, "table:" <> table_id}}
  end

  defp via_tuple(:last_added, table_id) do
    {:via, Registry, {LiveMenuOrder.Registry, "last_added:" <> table_id}}
  end
end
