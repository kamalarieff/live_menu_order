defmodule LiveMenuOrder.Repo.Migrations.AddStatusToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :status, :string, default: "active"
    end

    create constraint("orders", :status_must_be_valid, check: "status in ('active', 'inactive')")
  end
end
