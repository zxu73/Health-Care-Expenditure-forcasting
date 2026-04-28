defmodule MedicaidForecastWeb.ForecastLive do
  use MedicaidForecastWeb, :live_view

  alias MedicaidForecast.DataServer

  @default_state "New York"

  @impl true
  def mount(_params, _session, socket) do
    states   = DataServer.list_states()
    meta     = DataServer.meta()
    selected = @default_state
    state_data = build_state_data(selected, meta)

    {:ok,
     assign(socket,
       states:     states,
       selected:   selected,
       state_data: state_data,
       meta:       meta
     )}
  end

  @impl true
  def handle_event("select_state", %{"state" => state}, socket) do
    state_data = build_state_data(state, socket.assigns.meta)
    socket = assign(socket, selected: state, state_data: state_data)
    {:noreply, push_event(socket, "update_chart", state_data)}
  end

  defp build_state_data(state, meta) do
    case DataServer.get_state(state) do
      nil  -> %{}
      data ->
        data
        |> Map.put("state", state)
        |> Map.put("historical_years", meta["historical_years"])
        |> Map.put("forecast_years",   meta["forecast_years"])
    end
  end
end
