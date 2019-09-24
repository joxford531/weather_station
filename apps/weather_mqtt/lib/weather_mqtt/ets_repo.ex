defmodule WeatherMqtt.EtsRepo do
  use GenServer
  use Timex

  @timezone "America/New_York" # Eastern Time

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, nil}
  end

  def get_car() do
    get_key(:car_in_garage)
  end

  def get_dewpoint() do
    get_key(:dewpoint)
  end

  def get_humidity() do
    get_key(:humidity)
  end

  def get_pressure() do
    get_key(:pressure)
  end

  def get_temp() do
    get_key(:temp)
  end

  def put_car(car_in_garage) when is_number(car_in_garage) do
    :ets.insert(__MODULE__, {:car_in_garage, {car_in_garage, get_time()}})
  end

  def put_car(_car_in_garage), do: {:error, "not a number"}

  def put_dewpoint(dewpoint) when is_number(dewpoint) do
    :ets.insert(__MODULE__, {:dewpoint, {dewpoint, get_time()}})
  end

  def put_dewpoint(_dewpoint), do: {:error, "not a number"}

  def put_humidity(humidity) when is_number(humidity) do
    :ets.insert(__MODULE__, {:humidity, {humidity, get_time()}})
  end

  def put_humidity(_humidity), do: {:error, "not a number"}

  def put_pressure(pressure) when is_number(pressure) do
    :ets.insert(__MODULE__, {:pressure, {pressure, get_time()}})
  end

  def put_pressure(_dewpoint), do: {:error, "not a number"}

  def put_temp(temp) when is_number(temp) do
    :ets.insert(__MODULE__, {:temp, {temp, get_time()}})
  end

  def put_temp(_temp), do: {:error, "not a number"}

  defp get_key(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> {nil, nil}
    end
  end

  defp get_time() do
    {:ok, formatted_time} =
      Timex.now(@timezone)
      |> Timex.format("{h24}:{m}:{s} {Zabbr}")

    formatted_time
  end
end
