defmodule WeatherWeb.WeatherDaily do
  use Phoenix.LiveView
  use Timex

  def render(assigns) do
    ~L"""
    <div style="width:75%;">
      <canvas id="canvas" phx-update="ignore"></canvas>
    </div>
    <script>
      window.chartColors = {
        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(201, 203, 207)'
      };

      var config = {
        type: 'line',
        data: {
          datasets: [{
            label: 'Dataset with string point data',
            borderColor: window.chartColors.red,
            fill: false,
            data: <%= Phoenix.HTML.raw Jason.encode!(@data) %>
          }]
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
                labelString: 'value'
              }
            }]
          }
        }
      };
      window.onload = function() {
        var ctx = document.getElementById('canvas').getContext('2d');
        window.myLine = new Chart(ctx, config);
      };
    </script>

    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(60000, self(), :tick)

    {:ok, put_data(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_data(socket)}
  end

  def test() do
    start_time =
      Timex.now("America/New_York")
      |> Timex.beginning_of_day()

    end_time =
      Timex.now("America/New_York")
      |> Timex.end_of_day()

    data_points = WeatherMqtt.get_between_time(start_time, end_time)

    format_temp_data(data_points)
  end

  defp put_data(socket) do
    start_time =
      Timex.now("America/New_York")
      |> Timex.beginning_of_day()

    end_time =
      Timex.now("America/New_York")
      |> Timex.end_of_day()

    data_points = WeatherMqtt.get_between_time(start_time, end_time)

    assign(socket, data: format_temp_data(data_points))
  end

  defp format_temp_data(data_points) when is_list(data_points) do
    Enum.map(data_points, fn point ->
      %{
        x: Timex.to_datetime(point.time, "America/New_York") |> Timex.format!("{ISO:Extended}"),
        y: point.bmp_temp
      }
    end)
  end
end
