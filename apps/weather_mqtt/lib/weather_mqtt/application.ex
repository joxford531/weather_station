defmodule WeatherMqtt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: WeatherMqtt.Worker.start_link(arg)
      # {MqttHub.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherMqtt.Supervisor]
    Supervisor.start_link(children, opts)

    Tortoise.Supervisor.start_child(
      client_id: "my_client_id",
      handler: {WeatherMqtt.Handler, []},
      server: {Tortoise.Transport.Tcp, host: 'localhost', port: 1883},
      subscriptions: [{"front/temp_humidity", 0}]
    )

  end
end

