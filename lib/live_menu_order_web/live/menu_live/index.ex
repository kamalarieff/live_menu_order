defmodule LiveMenuOrderWeb.MenuLive.Index do
  use LiveMenuOrderWeb, :live_view

  alias LiveMenuOrder.Menus
  alias CartState

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: LiveMenuOrderWeb.Endpoint.subscribe("orders")
    cart = CartState.value()
    {:ok, assign(socket, menus: list_menus(), cart: cart)}
  end

  @impl true
  def handle_event("add", value, socket) do
    CartState.add(value)
    LiveMenuOrderWeb.Endpoint.broadcast("orders", "add_to_cart", value)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "add_to_cart", payload: payload}, socket) do
    new_cart = socket.assigns.cart ++ [payload]

    {:noreply,
     socket
     |> assign(:cart, new_cart)}
  end

  defp list_menus do
    Menus.list_menus()
  end
end

defmodule CartState do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def add(value) do
    Agent.update(__MODULE__, fn state ->
      state ++ [value]
    end)
  end
end
