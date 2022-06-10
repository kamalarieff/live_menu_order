defmodule LiveMenuOrderWeb.OrderLive.Show do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Tables

  @impl true
  def mount(_params, _session, socket) do
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

  defp page_title(:show), do: "Show Order"
  defp page_title(:edit), do: "Edit Order"
end
