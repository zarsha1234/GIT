defmodule Roc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RocWeb.Telemetry,
      Roc.Repo,
      {DNSCluster, query: Application.get_env(:roc, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Roc.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Roc.Finch},
      # Start a worker by calling: Roc.Worker.start_link(arg)
      # {Roc.Worker, arg},
      # Start to serve requests, typically the last entry
      RocWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Roc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
