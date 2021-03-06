defmodule WeatherWeb.Sensors do
  use Phoenix.LiveView
  alias WeatherBackend.EtsRepo, as: Repo
  require Logger

  def render(assigns) do
    ~L"""
    <div class="w-screen mt-2">
      <div class="container mx-auto px-4">
        <div class="font-mono flex flex-col">
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Dew Point: </h2>
              <div class="text-black text-3xl"><%= assigns[:data][:dewpoint] %>°F</div>
              <div class="text-black text-sm"><%= assigns[:data][:dewpoint_t] %></div>
            </div>
          </div>
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Humidity: </h2>
              <div class="text-black text-3xl"><%= assigns[:data][:humidity] %>%</div>
              <div class="text-black text-sm"><%= assigns[:data][:humidity_t] %></div>
            </div>
          </div>
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Pressure: </h2>
              <div class="text-black text-3xl"><%= assigns[:data][:pressure] %> inHg</div>
              <div class="text-black text-sm"><%= assigns[:data][:pressure_t] %></div>
            </div>
          </div>
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Temp (Bmp Sensor): </h2>
              <div class="text-black text-3xl"><%= assigns[:data][:temp_bmp] %>°F</div>
              <div class="text-black text-sm"><%= assigns[:data][:temp_bmp_t] %></div>
            </div>
          </div>
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Temp (Sht Sensor): </h2>
              <div class="text-black text-3xl"><%= assigns[:data][:temp_sht] %>°F</div>
              <div class="text-black text-sm"><%= assigns[:data][:temp_sht_t] %></div>
            </div>
          </div>
          <div class="my-1 bg-gray-300 rounded-lg shadow">
            <div class="text-center">
              <h2 class="text-xl"> Conditions: </h2>
              <div class="text-black text-sm"><%= assigns[:data][:conditions] %></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: subscribe_to_weather()

    {:ok, put_data(socket)}
  end

  def handle_info({:weather_update, data}, socket) do
    Logger.info("event: #{inspect(data)}")
    {:noreply, put_data(socket)}
  end

  defp subscribe_to_weather() do
    Phoenix.PubSub.subscribe(WeatherWeb.PubSub, "weather_data")
  end

  defp put_data(socket) do
    {car, car_t} = Repo.get_car()
    {dewpoint, dewpoint_t} = Repo.get_dewpoint()
    {humidity, humidity_t} = Repo.get_humidity()
    {pressure, pressure_t} = Repo.get_pressure()
    {temp_bmp, temp_bmp_t} = Repo.get_temp_bmp()
    {temp_sht, temp_sht_t} = Repo.get_temp_sht()
    conditions = WeatherBackend.get_latest_conditions()

    assign(socket, data: %{
        car: car,
        car_t: car_t,
        dewpoint: dewpoint,
        dewpoint_t: dewpoint_t,
        humidity: humidity,
        humidity_t: humidity_t,
        pressure: pressure,
        pressure_t: pressure_t,
        temp_bmp: temp_bmp,
        temp_bmp_t: temp_bmp_t,
        temp_sht: temp_sht,
        temp_sht_t: temp_sht_t,
        conditions: conditions
      }
    )
  end

end
