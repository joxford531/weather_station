defmodule WeatherBackendTest do
  use ExUnit.Case
  doctest WeatherBackend

  test "greets the world" do
    assert WeatherBackend.hello() == :world
  end
end
