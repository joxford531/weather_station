defmodule WeatherBackend.TortoiseSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {Tortoise.Connection,
        [
          client_id: System.get_env("MQTT_CLIENT_ID") || "weather_sensor_home",
          handler: {WeatherBackend.Handler, []},
          user_name: Application.get_env(:weather_backend, :broker_user) || System.get_env("MOSQUITTO_USER"),
          password: Application.get_env(:weather_backend, :broker_password) || System.get_env("MOSQUITTO_PW"),
          server: {
            Tortoise.Transport.Tcp,
            host: Application.get_env(:weather_backend, :broker_host) || System.get_env("MOSQUITTO_HOST"),
            port: (Application.get_env(:weather_backend, :broker_port) || System.get_env("MOSQUITTO_PORT"))
              |> String.to_integer()
          },
          subscriptions: [{"front/temp_humidity_dew_point_pressure", 0}]
        ]
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
