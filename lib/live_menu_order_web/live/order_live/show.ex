defmodule LiveMenuOrderWeb.OrderLive.Show do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Tables

  @impl true
  def mount(%{"table_id" => table_id}, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe(table_topic(table_id))
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"table_id" => table_id}, _, socket) do
    order = Tables.get_single_order_by_table(table_id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:order, order)}
  end

  @impl true
  def handle_info(%{event: "save_order"}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Order updated.")
     |> push_patch(to: Routes.order_show_path(socket, :show, socket.assigns.order.table_id))}
  end

  @impl true
  def handle_info(%{event: "update_state"}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "kick"}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Order closed.")
     |> push_redirect(to: Routes.menu_index_path(socket, :index, socket.assigns.order.table_id))}
  end

  defp page_title(:show), do: "Show Order"
  defp page_title(:edit), do: "Edit Order"

  defp table_topic(table_id) do
    "table:" <> table_id
  end
end
