defmodule WeatherWeb.WeatherHistory do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <div class="w-screen mt-2">
      <div class="flex flex-col md:flex-row lg:flex-row xl:flex-row md:justify-center">
        <div class="flex justify-center mb-2 md:my-0 md:pr-16">
          <label class="inline-flex items-center">
            <input type="radio" class="form-radio" name="dataPeriod" phx-click="time_period" value="hourly"
              <%= if @time_period == "hourly" do %>checked<% end %>
            >
            <span class="ml-2">Hourly</span>
          </label>
          <label class="inline-flex items-center ml-6">
            <input type="radio" class="form-radio" name="dataPeriod" phx-click="time_period" value="daily"
              <%= if @time_period == "daily" do %>checked<% end %>
            >
            <span class="ml-2">Daily</span>
          </label>
          <label class="inline-flex items-center ml-6">
            <input type="radio" class="form-radio" name="dataPeriod" phx-click="time_period" value="monthly"
              <%= if @time_period == "monthly" do %>checked<% end %>
            >
            <span class="ml-2">Monthly</span>
          </label>
        </div>
        <%= if @time_period != "monthly" do %>
          <div class="flex justify-center">
            <button class="w-auto bg-gray-300 hover:bg-gray-400 text-gray-800 border border-gray-400 font-normal py-2 px-4 rounded-l"
              phx-click="change_display" value="temperature">
              Temperature
            </button>
            <button class="w-auto bg-gray-300 hover:bg-gray-400 text-gray-800 border border-gray-400 font-normal py-2 px-4 rounded-1"
              phx-click="change_display" value="dewpoint">
              Dew Point
            </button>
            <button class="w-auto bg-gray-300 hover:bg-gray-400 text-gray-800 border border-gray-400 font-normal py-2 px-4 rounded-1"
              phx-click="change_display" value="pressure">
              Pressure
            </button>
            <button class="w-auto bg-gray-300 hover:bg-gray-400 text-gray-800 border border-gray-400 font-normal py-2 px-4 rounded-1"
              phx-click="change_display" value="rainfall">
              Rainfall
            </button>
          </div>
          <div class="flex justify-center mb-2 md:mb-0 md:pl-16 pt-2">
            <form phx-change="date_changed" phx-value-date="<%= @date_selected %>">
              <label for="dateSelected">Date:</label>
              <input type="date" id="dateSelected" name="date-selected" phx-debounce="1000"
                value="<%= (@date_selected) %>">
            </form>
            <%= if @time_period == "hourly" do %>
              <form phx-change="hour_changed" phx-value-date="<%= @hour_selected %>">
                <input type="time" id="hourSelected" name="hour-selected" phx-debounce="1000" step="3600"
                  value="<%= (@hour_selected) %>">
              </form>
            <% end %>
          </div>
        <% end %>
        <%= if @time_period == "monthly" do %>
        <div class="flex justify-center">
          <button class="w-auto bg-gray-300 hover:bg-gray-400 text-gray-800 border border-gray-400 font-normal py-2 px-4 rounded-1"
            phx-click="change_display" value="high_low_temps">
            High/Low Temps
          </button>
        </div>
          <div class="flex justify-center mb-2 md:mb-0 md:pl-16 pt-2">
            <form phx-change="month_changed" phx-value-date="<%= @month_year_selected %>">
              <label for="monthSelected">Month:</label>
              <input type="month" id="monthSelected" name="month-selected" phx-debounce="1000"
                value="<%= (@month_year_selected) %>">
            </form>
          </div>
        <% end %>
      </div>
      <div class="container mx-auto px-4">
        <%= if @display_section == "temperature" do %>
          <div id="temperature-holder" style="height: 38vh" data-bmp="<%= Jason.encode!(@bmp_data) %>"
            data-sht="<%= Jason.encode!(@sht_data) %>" data-period="<%= Jason.encode!(@time_period) %>" phx-hook="tempChart">
            <canvas id="canvas-temperature" phx-update="ignore"></canvas>
          </div>
          <div id="humidity-holder" style="height: 38vh" data-humidity="<%= Jason.encode!(@humidity) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="humidityChart">
            <canvas id="canvas-humidity" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "dewpoint" do %>
          <div id="dewpoint-holder" style="height: 75vh" data-dewpoint="<%= Jason.encode!(@dewpoint) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="dewpointChart">
            <canvas id="canvas-dewpoint" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "pressure" do %>
          <div id="pressure-holder" style="height: 75vh" data-pressure="<%= Jason.encode!(@pressure) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="pressureChart">
            <canvas id="canvas-pressure" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "rainfall" do %>
          <div id="rainfall-holder" style="height: 75vh" data-rainfall="<%= Jason.encode!(@rainfall) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="rainfallChart">
            <canvas id="canvas-rainfall" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "high_low_temps" do %>
          <div id="monthly-highlow-holder" style="height: 75vh"
            data-low="<%= Jason.encode!(@low_temps) %>"
            data-high="<%= Jason.encode!(@high_temps) %>"
            data-period="<%= Jason.encode!(@time_period) %>"
            phx-hook="monthlyHighLowChart">
            <canvas id="canvas-highlows" phx-update="ignore"></canvas>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: subscribe_to_weather()

    date_selected =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.to_date()

    hour_selected =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.format!("{h24}:00")

    month_year_selected =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.format!("{YYYY}-{0M}")

    socket =
      socket
      |> assign(:time_period, "hourly")
      |> assign(:display_section, "temperature")
      |> assign(:date_selected, date_selected)
      |> assign(:hour_selected, hour_selected)
      |> assign(:month_year_selected, month_year_selected)
      |> put_data()

    {:ok, socket}
  end

  def handle_info({:weather_update, _data}, socket) do
    Process.sleep(100) # wait for data to be persisted to DB
    {:noreply, put_data(socket)}
  end

  defp subscribe_to_weather() do
    Phoenix.PubSub.subscribe(WeatherWeb.PubSub, "weather_data")
  end

  def handle_event("time_period", %{"value" => value},
  %{assigns: %{date_selected: date_selected}} = socket) do

    today =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.to_date()

    new_date = if value == "hourly", do: today, else: date_selected # if hourly option is selected then reset date_selected\

    new_display = if value == "monthly", do: "high_low_temps", else: "temperature"

    socket =
      socket
      |> assign(:time_period, value)
      |> assign(:date_selected, new_date)
      |> assign(:display_section, new_display)
      |> put_data()

    {:noreply, socket}
  end

  def handle_event("change_display", %{"value" => value}, socket) do
    socket =
      socket
      |> assign(:display_section, value)

    {:noreply, socket}
  end

  def handle_event("date_changed", %{"date-selected" => new_date}, socket) do
    case new_date do
      "" -> {:noreply, socket}
      _ ->
        new_date_parsed =
          Timex.parse!(new_date, "{YYYY}-{0M}-{0D}")
          |> Timex.to_date()

        socket =
          socket
          |> assign(:date_selected, new_date_parsed)
          |> put_data()

        {:noreply, socket}
    end
  end

  def handle_event("hour_changed", %{"hour-selected" => new_hour}, socket) do

    case new_hour do
      "" -> {:noreply, socket}
      _ ->
        socket =
          socket
          |> assign(:hour_selected, new_hour)
          |> put_data()

        {:noreply, socket}
    end
  end

  def handle_event("month_changed", %{"month-selected" => new_month_year}, socket) do

    case new_month_year do
      "" -> {:noreply, socket}
      _ ->
        socket =
          socket
          |> assign(:month_year_selected, new_month_year)
          |> put_data()

        {:noreply, socket}
    end
  end

  defp put_data(%{assigns: %{time_period: time_period}} = socket) do
    case time_period do
      "monthly" -> put_monthly_data(socket)
      "hourly" -> put_hourly_data(socket)
      "daily" -> put_daily_data(socket)
      _ -> put_hourly_data(socket)
    end
  end

  defp put_monthly_data(%{assigns: %{month_year_selected: month_year_selected}} = socket) do
    start_time =
      month_year_selected
      |> Timex.parse!("%Y-%m", :strftime)
      |> Timex.to_datetime()
      |> Timex.beginning_of_month()

    end_time =
      month_year_selected
      |> Timex.parse!("%Y-%m", :strftime)
      |> Timex.to_datetime()
      |> Timex.end_of_month()

    {low_temps} =
      WeatherBackend.get_month_lows_raw(Timex.shift(start_time, days: 1), Timex.shift(end_time, hours: 12))
      |> Map.get(:rows)
      |> format_raw_monthly_results()

    {high_temps} =
      WeatherBackend.get_month_highs_raw(Timex.shift(start_time, hours: 12), end_time)
      |> Map.get(:rows)
      |> format_raw_monthly_results()

    assign(socket, low_temps: low_temps, high_temps: high_temps)
  end

  defp put_daily_data(%{assigns: %{date_selected: date_selected}} = socket) do
    start_time =
      date_selected
      |> Timex.to_datetime(Application.get_env(:weather_web, :timezone))
      |> Timex.beginning_of_day()
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      date_selected
      |> Timex.to_datetime(Application.get_env(:weather_web, :timezone))
      |> Timex.end_of_day()
      |> Timex.Timezone.convert("Etc/UTC")

    {bmp_temps, sht_temps, humidity, dewpoint, pressure, rainfall} =
      WeatherBackend.get_data_between_raw(start_time, end_time)
      |> Map.get(:rows)
      |> format_raw_daily_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps,
      humidity: humidity, dewpoint: dewpoint, pressure: pressure, rainfall: rainfall)
  end

  defp put_hourly_data(%{assigns: %{date_selected: date_selected, hour_selected: hour_selected}} = socket) do

    start_time =
      date_selected
      |> Timex.format!("%Y-%m-%d", :strftime)
      |> Kernel.<>(" #{hour_selected}")
      |> Timex.parse!("%Y-%m-%d %H:%M", :strftime)
      |> Timex.to_datetime(Application.get_env(:weather_web, :timezone))
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      start_time
      |> Timex.shift(hours: 1)

    {bmp_temps, sht_temps, humidity, dewpoint, pressure, rainfall} =
      WeatherBackend.get_history_between(start_time, end_time)
      |> format_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps,
      humidity: humidity, dewpoint: dewpoint, pressure: pressure, rainfall: rainfall)
  end

  defp format_results(rows) do
    bmp_temps = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.bmp_temp
      }
    end)

    sht_temps = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.sht_temp
      }
    end)

    humidity_values = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.humidity
      }
    end)

    dewpoint_values = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.dewpoint
      }
    end)

    pressure_values = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.pressure
      }
    end)

    rainfall_values = Enum.map(rows, fn row ->
      %{
        x: Timex.to_datetime(row.time, row.timezone) |> Timex.format!("{ISO:Extended}"),
        y: row.rainfall
      }
    end)

    {bmp_temps, sht_temps, humidity_values, dewpoint_values, pressure_values, rainfall_values}
  end

  defp format_raw_daily_results(rows) do
    bmp_temps = Enum.map(rows, fn [bmp, _sht, _humidity, _dewpoint, _pressure, _rainfall, timestamp] ->
      value = if is_nil(bmp), do: "#", else: Decimal.to_float(bmp)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    sht_temps = Enum.map(rows, fn [_bmp, sht, _humidity, _dewpoint, _pressure, _rainfall, timestamp] ->
      value = if is_nil(sht), do: "#", else: Decimal.to_float(sht)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    humidity_values = Enum.map(rows, fn [_bmp, _sht, humidity, _dewpoint, _pressure, _rainfall, timestamp] ->
      value = if is_nil(humidity), do: "#", else: Decimal.to_float(humidity)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    dewpoint_values = Enum.map(rows, fn [_bmp, _sht, _humidity, dewpoint, _pressure, _rainfall, timestamp] ->
      value = if is_nil(dewpoint), do: "#", else: Decimal.to_float(dewpoint)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    pressure_values = Enum.map(rows, fn [_bmp, _sht, _humidity, _dewpoint, pressure, _rainfall, timestamp] ->
      value = if is_nil(pressure), do: "#", else: Decimal.to_float(pressure)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    rainfall_values = Enum.map(rows, fn [_bmp, _sht, _humidity, _dewpoint, _pressure, rainfall, timestamp] ->
      value = if is_nil(rainfall), do: "#", else: Decimal.to_float(rainfall)
      %{
        x: Timex.to_datetime(timestamp, Application.get_env(:weather_web, :timezone)) |> Timex.format!("{ISO:Extended}"),
        y: value
      }
    end)

    {bmp_temps, sht_temps, humidity_values, dewpoint_values, pressure_values, rainfall_values}
  end

  defp format_raw_monthly_results(rows) do
    temps = Enum.map(rows, fn [timestamp, temp] ->
      value = if is_nil(temp), do: "#", else: temp
      %{
        x: Timex.parse!(timestamp, "%Y-%m-%d %H:%M:%S", :strftime)
          |> Timex.to_datetime(Application.get_env(:weather_web, :timezone))
          |> Timex.format!("{ISOdate}"),
        y: value
      }
    end)

    {temps}
  end
end
