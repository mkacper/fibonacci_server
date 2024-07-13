defmodule FibonacciServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FibonacciServerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fibonacci_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FibonacciServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FibonacciServer.Finch},
      # Start a worker by calling: FibonacciServer.Worker.start_link(arg)
      # {FibonacciServer.Worker, arg},
      # Start to serve requests, typically the last entry
      FibonacciServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FibonacciServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FibonacciServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
