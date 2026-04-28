defmodule MedicaidForecast.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MedicaidForecastWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:medicaid_forecast, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MedicaidForecast.PubSub},
      MedicaidForecast.DataServer,
      MedicaidForecastWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MedicaidForecast.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MedicaidForecastWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
