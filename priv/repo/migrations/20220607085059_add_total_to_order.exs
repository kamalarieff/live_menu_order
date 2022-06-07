defmodule LiveMenuOrder.Repo.Migrations.AddTotalToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :total, :float
    end
  end
end
