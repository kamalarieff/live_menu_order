defmodule LiveMenuOrder.Repo do
  use Ecto.Repo,
    otp_app: :live_menu_order,
    adapter: Ecto.Adapters.Postgres
end
