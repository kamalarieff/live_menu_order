defmodule LiveMenuOrder.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order, :map
      add :total, :float

      timestamps()
    end
  end
end
