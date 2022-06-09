defmodule LiveMenuOrderWeb.TableLive.FormComponent do
  use LiveMenuOrderWeb, :live_component

  alias LiveMenuOrder.Tables

  @impl true
  def update(%{table: table} = assigns, socket) do
    changeset = Tables.change_table(table)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"table" => table_params}, socket) do
    changeset =
      socket.assigns.table
      |> Tables.change_table(table_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"table" => table_params}, socket) do
    save_table(socket, socket.assigns.action, table_params)
  end

  defp save_table(socket, :edit, table_params) do
    case Tables.update_table(socket.assigns.table, table_params) do
      {:ok, _table} ->
        {:noreply,
         socket
         |> put_flash(:info, "Table updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_table(socket, :new, table_params) do
    case Tables.create_table(table_params) do
      {:ok, _table} ->
        {:noreply,
         socket
         |> put_flash(:info, "Table created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
