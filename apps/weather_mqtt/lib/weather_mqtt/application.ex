defmodule WeatherMqtt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      WeatherMqtt.EtsRepo
    ]

    {:ok, _pid} =
      Tortoise.Supervisor.start_child(
        client_id: "weather_sensor_home",
        handler: {WeatherMqtt.Handler, []},
        user_name: Application.get_env(:weather_sensor, :broker_user) || System.get_env("BROKER_USER"),
        password: Application.get_env(:weather_sensor, :broker_password) || System.get_env("BROKER_PASSWORD"),
        server: {
          Tortoise.Transport.Tcp,
          host: Application.get_env(:weather_sensor, :broker_host) || System.get_env("BROKER_HOST"),
          port: Application.get_env(:weather_sensor, :broker_port) ||
            (System.get_env("BROKER_PORT") |> String.to_integer())
        },
        subscriptions: [{"front/temp_humidity_dew_point_pressure", 0}, {"garage/car", 0}])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherMqtt.Supervisor]
    Supervisor.start_link(children, opts)

  end
end

