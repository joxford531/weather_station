defmodule WeatherWeb.Sensors do
  use Phoenix.LiveView
  alias WeatherMqtt.EtsRepo, as: Repo

  def render(assigns) do
    ~L"""
    <div class="w-screen">
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
              <h2 class="text-xl"> Car in Garage: </h2>
                <%= if assigns[:data][:car] == 1 do %>
                  <i class="fas fa-car text-4xl text-red-600"></i>
                <% else %>
                  <i class="fas fa-check text-4xl text-green-600"></i>
                <% end %>
                <div class="text-black text-sm"><%= assigns[:car][:car_t] %></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, put_data(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_data(socket)}
  end

  defp put_data(socket) do
    {car, car_t} = Repo.get_car()
    {dewpoint, dewpoint_t} = Repo.get_dewpoint()
    {humidity, humidity_t} = Repo.get_humidity()
    {pressure, pressure_t} = Repo.get_pressure()
    {temp_bmp, temp_bmp_t} = Repo.get_temp_bmp()
    {temp_sht, temp_sht_t} = Repo.get_temp_sht()

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
        temp_sht_t: temp_sht_t
      }
    )
  end

end
