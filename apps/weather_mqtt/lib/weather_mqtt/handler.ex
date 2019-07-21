defmodule WeatherMqtt.Handler do
  use Tortoise.Handler

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    IO.puts("connection status #{status}")
    {:ok, state}
  end

  #  topic filter room/temp_humidity
  def handle_message(["front", "temp_humidity"], payload, state) do
    # :ok = Temperature.record(room, payload)
    IO.puts("payload #{payload}")
    case Jason.decode(payload) do
      {:ok, %{"humidity" => humidity, "temp" => temp}} -> IO.puts("humidity #{humidity}, temp: #{temp}")
      _ -> IO.puts("could not decode message")
    end
    {:ok, state}
  end
  def handle_message(topic, payload, state) do
    # unhandled message! You will crash if you subscribe to something
    # and you don't have a 'catch all' matcher; crashing on unexpected
    # messages could be a strategy though.
    IO.puts("unhandled message topic: #{topic} payload: #{payload} state: #{state}")
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
