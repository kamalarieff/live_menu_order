defmodule LiveMenuOrder.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order, :map
    field :total, :float
    belongs_to :table, LiveMenuOrder.Tables.Table

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order, :total, :table_id])
    |> validate_required([:order, :total, :table_id])
  end
end
