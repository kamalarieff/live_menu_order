defmodule LiveMenuOrder.MenusTest do
  use LiveMenuOrder.DataCase

  alias LiveMenuOrder.Menus

  describe "menus" do
    alias LiveMenuOrder.Menus.Menu

    import LiveMenuOrder.MenusFixtures

    @invalid_attrs %{name: nil}

    test "list_menus/0 returns all menus" do
      menu = menu_fixture()
      assert Menus.list_menus() == [menu]
    end

    test "get_menu!/1 returns the menu with given id" do
      menu = menu_fixture()
      assert Menus.get_menu!(menu.id) == menu
    end

    test "create_menu/1 with valid data creates a menu" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Menu{} = menu} = Menus.create_menu(valid_attrs)
      assert menu.name == "some name"
    end

    test "create_menu/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu(@invalid_attrs)
    end

    test "update_menu/2 with valid data updates the menu" do
      menu = menu_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Menu{} = menu} = Menus.update_menu(menu, update_attrs)
      assert menu.name == "some updated name"
    end

    test "update_menu/2 with invalid data returns error changeset" do
      menu = menu_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu(menu, @invalid_attrs)
      assert menu == Menus.get_menu!(menu.id)
    end

    test "delete_menu/1 deletes the menu" do
      menu = menu_fixture()
      assert {:ok, %Menu{}} = Menus.delete_menu(menu)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu!(menu.id) end
    end

    test "change_menu/1 returns a menu changeset" do
      menu = menu_fixture()
      assert %Ecto.Changeset{} = Menus.change_menu(menu)
    end
  end
end
