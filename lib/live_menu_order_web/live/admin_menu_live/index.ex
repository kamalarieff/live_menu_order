defmodule LiveMenuOrderWeb.AdminMenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias LiveMenuOrder.Menus.Menu

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :menus, list_menus())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Menu")
    |> assign(:menu, Menus.get_menu!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Menu")
    |> assign(:menu, %Menu{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Menus")
    |> assign(:menu, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    menu = Menus.get_menu!(id)
    {:ok, _} = Menus.delete_menu(menu)

    {:noreply, assign(socket, :menus, list_menus())}
  end

  defp list_menus do
    Menus.list_menus()
  end
end
