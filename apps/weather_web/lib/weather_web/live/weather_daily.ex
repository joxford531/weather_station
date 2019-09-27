defmodule WeatherWeb.WeatherDaily do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <div id="canvas-holder" data-bmp="<%= Jason.encode!(@bmp_data) %>"
    data-sht="<%= Jason.encode!(@sht_data) %>" phx-hook="chart">
      <canvas id="canvas" phx-update="ignore"></canvas>
    </div>
    <script>
      let myLine = null;

      let chartColors = {
        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(201, 203, 207)'
      };

      config = {
        type: 'line',
        data: {
          datasets: [
            {
              label: 'BMP180 Temp',
              borderColor: chartColors.red,
              fill: false,
              data: <%= Phoenix.HTML.raw Jason.encode!(@bmp_data) %>
            },
            {
              label: 'SHT31 Temp',
              borderColor: chartColors.blue,
              fill: false,
              data: <%= Phoenix.HTML.raw Jason.encode!(@sht_data) %>
            }
          ]
        },
        options: {
          responsive: true,
          title: {
            display: true,
            text: 'Chart.js Time Point Data'
          },
          scales: {
            xAxes: [{
              type: 'time',
              display: true,
              scaleLabel: {
                display: true,
                labelString: 'Date'
              },
              ticks: {
                major: {
                  fontStyle: 'bold',
                  fontColor: '#FF0000'
                }
              }
            }],
            yAxes: [{
              display: true,
              scaleLabel: {
                display: true,
                labelString: 'Temp F'
              }
            }]
          }
        }
      };

      window.onload = () => {
        let ctx = document.getElementById('canvas').getContext('2d');
        myLine = new Chart(ctx, config);

        setInterval(() => {
          updateData();
        }, 3000)
      };

      updateData = () => {
        let el = document.getElementById("canvas-holder")
        config.data.datasets[0].data = JSON.parse(el.dataset.bmp);
        config.data.datasets[1].data = JSON.parse(el.dataset.sht);

        console.log(config.data.datasets[0].data[config.data.datasets[0].data.length - 1])

        myLine.update();
      }
    </script>

    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(3000, self(), :tick)

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
