defmodule WeatherBackend.EtsRepo do
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

  def get_temp_bmp() do
    get_key(:temp_bmp)
  end

  def get_temp_sht() do
    get_key(:temp_sht)
  end

  def put_dewpoint(dewpoint) when is_number(dewpoint) do
    put_key_value(:dewpoint, dewpoint)
  end

  def put_dewpoint(_dewpoint), do: {:error, "not a number"}

  def put_humidity(humidity) when is_number(humidity) do
    put_key_value(:humidity, humidity)
  end

  def put_humidity(_humidity), do: {:error, "not a number"}

  def put_pressure(pressure) when is_number(pressure) do
    put_key_value(:pressure, pressure)
  end

  def put_pressure(_dewpoint), do: {:error, "not a number"}

  def put_temp_bmp(temp) when is_number(temp) do
    put_key_value(:temp_bmp, temp)
  end

  def put_temp_bmp(_temp), do: {:error, "not a number"}

  def put_temp_sht(temp) when is_number(temp) do
    put_key_value(:temp_sht, temp)
  end

  def put_temp_sht(_temp), do: {:error, "not a number"}

  defp get_key(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> {nil, nil}
    end
  end

  defp put_key_value(key, value) do
    :ets.insert(__MODULE__, {key, {value, get_time()}})
  end

  defp get_time() do
    {:ok, formatted_time} =
      Timex.now(@timezone)
      |> Timex.format("{h24}:{m}:{s} {Zabbr}")

    formatted_time
  end
end
