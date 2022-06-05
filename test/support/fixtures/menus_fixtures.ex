defmodule LiveMenuOrder.MenusFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveMenuOrder.Menus` context.
  """

  @doc """
  Generate a menu.
  """
  def menu_fixture(attrs \\ %{}) do
    {:ok, menu} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> LiveMenuOrder.Menus.create_menu()

    menu
  end
end
