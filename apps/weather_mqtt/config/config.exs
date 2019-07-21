# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :weather_mqtt, ecto_repos: [WeatherMqtt.Repo]

config :weather_mqtt, WeatherMqtt.Repo,
  database: "Weather",
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PW") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  port: "5432"
