defmodule LiveMenuOrder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      LiveMenuOrder.Repo,
      # Start the Telemetry supervisor
      LiveMenuOrderWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveMenuOrder.PubSub},
      # Start the Endpoint (http/https)
      LiveMenuOrderWeb.Endpoint,
      # Start a worker by calling: LiveMenuOrder.Worker.start_link(arg)
      # {LiveMenuOrder.Worker, arg},
      CartState
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveMenuOrder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveMenuOrderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
