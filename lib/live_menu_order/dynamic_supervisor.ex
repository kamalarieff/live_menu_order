defmodule LiveMenuOrder.DynamicSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def terminate_all_children do
    children = DynamicSupervisor.which_children(__MODULE__)
    for {_id, pid, _type, _module} <- children do
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
