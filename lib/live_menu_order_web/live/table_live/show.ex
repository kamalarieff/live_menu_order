defmodule LiveMenuOrderWeb.TableLive.Show do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Tables

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    table = Tables.get_table!(id)
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:table, table)}
  end

  defp page_title(:show), do: "Show Table"
  defp page_title(:edit), do: "Edit Table"
end
