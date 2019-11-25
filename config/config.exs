# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :weather_web,
  generators: [context_app: false]

config :weather_web, WeatherWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "email-smtp.us-east-1.amazonaws.com",
  hostname: "joxylogic.com",
  port: 587,
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always,
  ssl: false,
  retries: 1,
  auth: :always

config :weather_web,
  sending_address: "noreply@joxylogic.com"

# Configures the endpoint
config :weather_web, WeatherWeb.Endpoint,
  url: [host: nil],
  secret_key_base: "vbvvs9DumpM3VSut2zXoewGnXkTc9hoqgXZk3PsMK11wG/LV56RAC1RUcZGFE1rq",
  render_errors: [view: WeatherWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WeatherWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "zTsbIWFxQmIdC/GelUnTmEEmGFwvduzt"
  ]

# By default, the umbrella project as well as each child
# application will require this configuration file, as
# configuration and dependencies are shared in an umbrella
# project. While one could configure all applications here,
# we prefer to keep the configuration of each individual
# child application in their own app, but all other
# dependencies, regardless if they belong to one or multiple
# apps, should be configured in the umbrella to avoid confusion.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
