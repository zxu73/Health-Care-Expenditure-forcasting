defmodule MedicaidForecast.DataServer do
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def list_states, do: GenServer.call(__MODULE__, :list_states)
  def get_state(name), do: GenServer.call(__MODULE__, {:get_state, name})
  def meta, do: GenServer.call(__MODULE__, :meta)

  @impl true
  def init(_) do
    path = Application.app_dir(:medicaid_forecast, "priv/data/all_states_forecast.json")
    data = path |> File.read!() |> Jason.decode!()
    {:ok, data}
  end

  @impl true
  def handle_call(:list_states, _from, state), do: {:reply, state["states"], state}

  @impl true
  def handle_call({:get_state, name}, _from, state), do: {:reply, state["data"][name], state}

  @impl true
  def handle_call(:meta, _from, state) do
    meta = %{
      "historical_years" => state["historical_years"],
      "forecast_years"   => state["forecast_years"],
      "generated_at"     => state["generated_at"]
    }
    {:reply, meta, state}
  end
end
