defmodule FoldingInElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoldingInElixirWeb.Telemetry,
      FoldingInElixir.Repo,
      {DNSCluster, query: Application.get_env(:folding_in_elixir, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FoldingInElixir.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: FoldingInElixir.Finch},
      # Start a worker by calling: FoldingInElixir.Worker.start_link(arg)
      # {FoldingInElixir.Worker, arg},
      # Start to serve requests, typically the last entry
      FoldingInElixirWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FoldingInElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoldingInElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
