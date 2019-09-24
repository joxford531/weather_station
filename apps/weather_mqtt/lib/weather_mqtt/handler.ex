defmodule WeatherMqtt.Handler do
  use Tortoise.Handler
  alias WeatherMqtt.EtsRepo, as: Repo
  require Logger

  def init(args) do
    Logger.info("Handler init")
    {:ok, args}
  end

  def connection(_status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    {:ok, state}
  end

  #  topic filter room/+/temp
  def handle_message(["front", "temp_humidity_dew_point_pressure"], payload, state) do
    %{"humidity" => humidity,
      "temp" => temp,
      "dew_point" => dew_point,
      "pressure" => pressure} = Jason.decode!(payload)

    Repo.put_dewpoint(dew_point)
    Repo.put_humidity(humidity)
    Repo.put_pressure(pressure)
    Repo.put_temp(temp)

    # Logger.info("Handled data: humidity => #{humidity} temp => #{temp} dew_point => #{dew_point} pressure => #{pressure}")

    {:ok, state}
  end

  def handle_message(["garage", "car"], payload, state) do
    String.to_integer(payload) |> Repo.put_car()
    # Logger.info("Handled data: car => #{payload}")

    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    # unhandled message! You will crash if you subscribe to something
    # and you don't have a 'catch all' matcher; crashing on unexpected
    # messages could be a strategy though.
    Logger.info("unhandled message with topic #{topic}!")
    Logger.info("payload #{inspect(payload)}")
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    # tortoise doesn't care about what you return from terminate/2,
    # that is in alignment with other behaviours that implement a
    # terminate-callback
    :ok
  end
end
