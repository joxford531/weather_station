# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :weather_backend, ecto_repos: [WeatherBackend.Repo]

config :weather_backend, WeatherBackend.Repo,
  database: "Weather",
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PW") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: "5432"

config :weather_backend,
  broker_user: System.get_env("MOSQUITTO_USER"),
  broker_password: System.get_env("MOSQUITTO_PW"),
  broker_host: System.get_env("MOSQUITTO_HOST"),
  broker_port: System.get_env("MOSQUITTO_PORT")
