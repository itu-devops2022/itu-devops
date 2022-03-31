defmodule MinitwitElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MinitwitElixir.Repo,
      # Start the Prometheus
      MinitwitElixir.PromEx,
      # Start the Telemetry supervisor
      MinitwitElixirWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MinitwitElixir.PubSub},
      # Start the Endpoint (http/https)
      MinitwitElixirWeb.Endpoint
      # Start a worker by calling: MinitwitElixir.Worker.start_link(arg)
      # {MinitwitElixir.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MinitwitElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MinitwitElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
