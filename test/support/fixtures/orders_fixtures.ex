defmodule LiveMenuOrder.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveMenuOrder.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        order: %{}
      })
      |> LiveMenuOrder.Orders.create_order()

    order
  end
end
