defmodule WeatherMqttTest do
  use ExUnit.Case
  doctest WeatherMqtt

  test "greets the world" do
    assert WeatherMqtt.hello() == :world
  end
end
