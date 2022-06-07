defmodule LiveMenuOrder.Repo.Migrations.AddPriceToMenu do
  use Ecto.Migration

  def change do
    alter table(:menus) do
      add :price, :float
    end
  end
end
