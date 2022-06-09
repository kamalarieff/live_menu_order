defmodule LiveMenuOrder.Tables.Table do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tables" do
    has_many :orders, LiveMenuOrder.Orders.Order

    timestamps()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [])
    |> validate_required([])
  end
end
