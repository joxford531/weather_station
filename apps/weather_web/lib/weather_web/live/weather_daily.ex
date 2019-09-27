defmodule WeatherWeb.WeatherDaily do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <div id="canvas-holder" data-bmp="<%= Jason.encode!(@bmp_data) %>"
      data-sht="<%= Jason.encode!(@sht_data) %>" phx-hook="chart">
      <canvas id="canvas" phx-update="ignore"></canvas>
    </div>

    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(30000, self(), :tick)

    {:ok, put_hourly_data(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_hourly_data(socket)}
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

    {bmp_temps, sht_temps} =
      WeatherMqtt.get_temps_between_raw(start_time, end_time)
      |> Map.get(:rows)
      |> format_raw_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps)
  end

  defp put_hourly_data(socket) do
    start_time =
      Timex.now("America/New_York")
      |> Timex.shift(hours: -1)
      |> Timex.Timezone.convert("Etc/UTC")

    end_time =
      Timex.now("America/New_York")
      |> Timex.Timezone.convert("Etc/UTC")

    {bmp_temps, sht_temps} =
      WeatherMqtt.get_history_between(start_time, end_time)
      |> format_results()

    assign(socket, bmp_data: bmp_temps, sht_data: sht_temps)
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

    {bmp_temps, sht_temps}
  end

  defp format_raw_results(rows) do
    bmp_temps = Enum.map(rows, fn [bmp, _sht, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(bmp)
      }
    end)

    sht_temps = Enum.map(rows, fn [_bmp, sht, timestamp] ->
      %{
        x: Timex.to_datetime(timestamp, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: Decimal.to_float(sht)
      }
    end)

    {bmp_temps, sht_temps}
  end
end
