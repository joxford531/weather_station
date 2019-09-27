defmodule WeatherMqtt do
  import Ecto.Query, warn: false
  alias WeatherMqtt.Repo

  alias WeatherMqtt.{History}


  def get_between_time(start_time, end_time) do
    Repo.all(
      from h in History,
      where: h.time >= ^start_time and h.time < ^end_time,
      order_by: [asc: h.time]
    )
  end
end
