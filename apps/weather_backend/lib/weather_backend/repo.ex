defmodule WeatherBackend.Repo do
  use Ecto.Repo,
    otp_app: :weather_backend,
    adapter: Ecto.Adapters.Postgres
end
