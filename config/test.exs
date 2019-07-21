use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weather_web, WeatherWeb.Endpoint,
  http: [port: 4002],
  server: false
