defmodule LiveMenuOrderWeb.TableLive.Show do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Tables
  alias LiveMenuOrder.Orders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe(table_topic(id))
    table = Tables.get_table!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:table, table)}
  end

  @impl true
  def handle_event("pay", value, socket) do
    order = Orders.get_order!(value["id"])
    {:ok, _} = Orders.update_order(order, %{status: "inactive"})

    LiveMenuOrderWeb.Endpoint.broadcast(
      table_topic(socket.assigns.table.id),
      "kick",
      nil
    )

    {:noreply,
     socket
     |> push_patch(to: Routes.table_show_path(socket, :show, socket.assigns.table))}
  end

  @impl true
  def handle_info(%{event: "save_order"}, socket) do
    table = Tables.get_table!(socket.assigns.table.id)

    {:noreply,
     socket
     |> assign(:table, table)}
  end

  @impl true
  def handle_info(%{event: "update_state"}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "kick"}, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Table"
  defp page_title(:edit), do: "Edit Table"

  defp table_topic(table_id) when is_integer(table_id) do
    "table:" <> Integer.to_string(table_id)
  end

  defp table_topic(table_id) do
    "table:" <> table_id
  end
end
