defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :menus, list_menus())}
  end

  defp list_menus do
    Menus.list_menus()
  end
end
