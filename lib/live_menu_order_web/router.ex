defmodule LiveMenuOrderWeb.Router do
  use LiveMenuOrderWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveMenuOrderWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveMenuOrderWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/admin/menus", AdminMenuLive.Index, :index
    live "/admin/menus/new", AdminMenuLive.Index, :new
    live "/admin/menus/:id/edit", AdminMenuLive.Index, :edit

    live "/admin/menus/:id", AdminMenuLive.Show, :show
    live "/admin/menus/:id/show/edit", AdminMenuLive.Show, :edit

    live "/admin/tables", TableLive.Index, :index
    live "/admin/tables/new", TableLive.Index, :new
    live "/admin/tables/:id/edit", TableLive.Index, :edit

    live "/admin/tables/:id", TableLive.Show, :show
    live "/admin/tables/:id/show/edit", TableLive.Show, :edit

    live "/table/:table_id/menu", MenuLive.Index, :index
    live "/table/:table_id/order", OrderLive.Show, :show
    live "/menu/:id", MenuLive.Show, :show
    live "/menu/:menu_id/table/:table_id", MenuLive.ShowTable, :show

    live "/admin/orders", OrderLive.Index, :index
    live "/admin/orders/new", OrderLive.Index, :new
    live "/admin/orders/:id/edit", OrderLive.Index, :edit

    live "/admin/orders/:id", OrderLive.Show, :show
    live "/admin/orders/:id/show/edit", OrderLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveMenuOrderWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveMenuOrderWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
