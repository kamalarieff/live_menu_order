defmodule LiveMenuOrder.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order, :map
    field :total, :float

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order, :total])
    |> validate_required([:order, :total])
  end
end
