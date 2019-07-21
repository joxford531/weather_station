defmodule WeatherMqtt.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather_mqtt,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {WeatherMqtt.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tortoise, "~> 0.9"},
      {:jason, "~> 1.1"},
      {:ecto_sql, "~> 3.1.6"},
      {:postgrex, "~> 0.14.1"},
      {:comeonin, "~> 4.1"},
      {:pbkdf2_elixir, "~> 0.12"}
    ]
  end
end
