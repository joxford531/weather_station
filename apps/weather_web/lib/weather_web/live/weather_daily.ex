defmodule WeatherWeb.WeatherDaily do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <div class="w-screen">
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
      </div>
      <div class="container mx-auto px-4">
        <%= if @display_section == "temperature" do %>
          <div id="temperature-holder" style="height: 40vh" data-bmp="<%= Jason.encode!(@bmp_data) %>"
            data-sht="<%= Jason.encode!(@sht_data) %>" data-period="<%= Jason.encode!(@time_period) %>" phx-hook="tempChart">
            <canvas id="canvas-temperature" phx-update="ignore"></canvas>
          </div>
          <div id="humidity-holder" style="height: 40vh" data-humidity="<%= Jason.encode!(@humidity) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="humidityChart">
            <canvas id="canvas-humidity" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "dewpoint" do %>
          <div id="dewpoint-holder" style="height: 80vh" data-dewpoint="<%= Jason.encode!(@dewpoint) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="dewpointChart">
            <canvas id="canvas-dewpoint" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <%= if @display_section == "pressure" do %>
          <div id="pressure-holder" style="height: 80vh" data-pressure="<%= Jason.encode!(@pressure) %>"
            data-period="<%= Jason.encode!(@time_period) %>" phx-hook="pressureChart">
            <canvas id="canvas-pressure" phx-update="ignore"></canvas>
          </div>
        <% end %>
        <div class="container mx-auto px-4">
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
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    timer_ref =
      if connected?(socket), do: Process.send_after(self(), :tick, 1000)

    socket =
      socket
      |> assign(:time_period, "hourly")
      |> assign(:display_section, "temperature")
      |> assign(:timer_ref, timer_ref)
      |> put_data()

    {:ok, socket}
  end

  def handle_event("time_period", %{"value" => value}, %{assigns: %{timer_ref: ref}} = socket) do
    Process.cancel_timer(ref)

    ref = Process.send_after(self(), :tick, 500)

    socket =
      socket
      |> assign(:time_period, value)
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

  defp put_daily_data(socket) do
    start_time =
      Timex.now("America/New_York")
      |> Timex.beginning_of_day()
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      Timex.now("America/New_York")
      |> Timex.end_of_day()
      |> Timex.Timezone.convert("Etc/UTC")

    {bmp_temps, sht_temps, humidity, dewpoint, pressure} =
      WeatherMqtt.get_data_between_raw(start_time, end_time)
      |> Map.get(:rows)
      |> format_raw_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps, humidity: humidity, dewpoint: dewpoint, pressure: pressure)
  end

  defp put_hourly_data(socket) do
    start_time =
      Timex.now("America/New_York")
      |> Timex.shift(hours: -1)
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      Timex.now("America/New_York")
      |> Timex.Timezone.convert("Etc/UTC")

    {bmp_temps, sht_temps, humidity, dewpoint, pressure} =
      WeatherMqtt.get_history_between(start_time, end_time)
      |> format_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps, humidity: humidity, dewpoint: dewpoint, pressure: pressure)
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

    {bmp_temps, sht_temps, humidity_values, dewpoint_values, pressure_values}
  end

  defp format_raw_results(rows) do
    bmp_temps = Enum.map(rows, fn [bmp, _sht, _humidity, _dewpoint, _pressure, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(bmp)
      }
    end)

    sht_temps = Enum.map(rows, fn [_bmp, sht, _humidity, _dewpoint, _pressure, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(sht)
      }
    end)

    humidity_values = Enum.map(rows, fn [_bmp, _sht, humidity, _dewpoint, _pressure, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(humidity)
      }
    end)

    dewpoint_values = Enum.map(rows, fn [_bmp, _sht, _humidity, dewpoint, _pressure, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(dewpoint)
      }
    end)

    pressure_values = Enum.map(rows, fn [_bmp, _sht, _humidity, _dewpoint, pressure, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(pressure)
      }
    end)

    {bmp_temps, sht_temps, humidity_values, dewpoint_values, pressure_values}
  end
end
