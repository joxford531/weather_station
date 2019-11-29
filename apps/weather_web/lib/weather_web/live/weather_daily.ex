defmodule WeatherWeb.WeatherDaily do
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
        </div>
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
              value="<%= (@date_selected) %>" <%= if @time_period == "hourly" do %>disabled<% end %>>
          </form>
        </div>
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
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    timer_ref =
      if connected?(socket), do: Process.send_after(self(), :tick, 1000)

    today =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.to_date()

    socket =
      socket
      |> assign(:time_period, "hourly")
      |> assign(:display_section, "temperature")
      |> assign(:date_selected, today)
      |> assign(:timer_ref, timer_ref)
      |> put_data()

    {:ok, socket}
  end

  def handle_event("time_period", %{"value" => value}, %{assigns: %{timer_ref: ref, date_selected: date_selected}} = socket) do
    Process.cancel_timer(ref)
    ref = Process.send_after(self(), :tick, 500)

    today =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.to_date()

    new_date = if value == "hourly", do: today, else: date_selected # if hourly option is selected then reset date_selected

    socket =
      socket
      |> assign(:time_period, value)
      |> assign(:date_selected, new_date)
      |> assign(:timer_ref, ref)

    {:noreply, socket}
  end

  def handle_event("change_display", %{"value" => value}, %{assigns: %{timer_ref: ref}} = socket) do
    Process.cancel_timer(ref)
    ref = Process.send_after(self(), :tick, 500)

    socket =
      socket
      |> assign(:display_section, value)
      |> assign(:timer_ref, ref)

    {:noreply, socket}
  end

  def handle_event("date_changed", %{"date-selected" => new_date}, %{assigns: %{timer_ref: ref}} = socket) do
    IO.puts("date selected: #{inspect(new_date)}")
    case new_date do
      "" -> {:noreply, socket}
      _ ->
        Process.cancel_timer(ref)
        updated_ref = Process.send_after(self(), :tick, 30000)
        new_date_parsed =
          Timex.parse!(new_date, "{YYYY}-{0M}-{0D}")
          |> Timex.to_date()

        socket =
          socket
          |> assign(:timer_ref, updated_ref)
          |> assign(:date_selected, new_date_parsed)
          |> put_data()

        {:noreply, socket}
    end
  end

  def handle_info(:tick, %{assigns: %{timer_ref: ref}} = socket) do
    Process.cancel_timer(ref)
    socket = put_data(socket)
    updated_ref = Process.send_after(self(), :tick, 30000)

    {:noreply, assign(socket, :timer_ref, updated_ref)}
  end

  defp put_data(%{assigns: %{time_period: time_period}} = socket) do
    case time_period do
      "hourly" -> put_hourly_data(socket)
      "daily" -> put_daily_data(socket)
      _ -> put_hourly_data(socket)
    end
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
      |> format_raw_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps,
      humidity: humidity, dewpoint: dewpoint, pressure: pressure, rainfall: rainfall)
  end

  defp put_hourly_data(socket) do
    start_time =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.shift(hours: -1)
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      Timex.now(Application.get_env(:weather_web, :timezone))
      |> Timex.Timezone.convert("Etc/UTC")

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

  defp format_raw_results(rows) do
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
end
