defmodule WeatherMqtt.Repo do
  use Ecto.Repo,
    otp_app: :weather_mqtt,
    adapter: Ecto.Adapters.Postgres
end
