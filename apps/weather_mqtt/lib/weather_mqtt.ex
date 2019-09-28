defmodule WeatherMqtt do
  import Ecto.Query, warn: false
  alias WeatherMqtt.Repo

  alias WeatherMqtt.{History}


  def get_history_between(start_time, end_time) do
    Repo.all(
      from h in History,
      where: h.time >= ^start_time and h.time < ^end_time,
      order_by: [asc: h.time]
    )
  end

  def get_temps_between_raw(start_time, end_time) do
    query = """
    SELECT
      ROUND(CAST(MAX(bmp_temp) as NUMERIC), 2) as bmp_temp,
      ROUND(CAST(MAX(sht_temp) as NUMERIC), 2) as sht_temp,
      to_timestamp(
        floor(
          (
            extract(
              'epoch'
                from
                time
              ) / 600
          )
        ) * 600
      ) as time_period
    FROM
      history
    WHERE
	    time >= $1 AND time <= $2
    GROUP BY
      time_period
    ORDER BY
      time_period asc;
    """
    Ecto.Adapters.SQL.query!(Repo, query, [start_time, end_time])
  end
end
