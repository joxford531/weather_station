defmodule WeatherUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        aws: [
          include_executables_for: [:unix],
          config_providers: [
            {TomlConfigProvider, path: "/srv/weather-station/etc/config.toml"}
          ],
          steps: [:assemble, :tar]
        ],
        web: [
          include_executables_for: [:unix],
          applications: [
            weather_backend: :permanent,
            weather_web: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:mix_deploy, "~> 0.7"},
      {:toml_config, "~> 0.1.0"}, # Mix releases
    ]
  end
end
