defmodule LiveMenuOrder.Repo.Migrations.AddOrderReferenceToTables do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :table_id, references("tables")
    end
  end
end
