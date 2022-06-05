defmodule LiveMenuOrderWeb.MenuLive.Show do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:menu, Menus.get_menu!(id))}
  end

  defp page_title(:show), do: "Show Menu"
end
