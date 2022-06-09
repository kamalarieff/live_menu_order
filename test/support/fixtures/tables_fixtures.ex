defmodule LiveMenuOrder.TablesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveMenuOrder.Tables` context.
  """

  @doc """
  Generate a table.
  """
  def table_fixture(attrs \\ %{}) do
    {:ok, table} =
      attrs
      |> Enum.into(%{

      })
      |> LiveMenuOrder.Tables.create_table()

    table
  end
end
