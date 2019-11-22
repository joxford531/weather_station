defmodule WeatherWeb.Pipeline.EmailHandler do
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:consumer, :ok, subscribe_to: [{WeatherWeb.Pipeline.EmailBroadcaster, max_demand: 1}]}
  end

  def handle_events([event], _from, state) do
    IO.puts("received #{inspect(event)}")

    {:noreply, [], state}
  end
end
