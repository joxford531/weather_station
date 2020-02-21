defmodule WeatherBackend do
  import Ecto.Query, warn: false
  alias WeatherBackend.Repo

  alias WeatherBackend.Records.History

  def get_history_between(start_time, end_time) do
    Repo.all(
      from h in History,
      where: h.time >= ^start_time and h.time < ^end_time,
      order_by: [asc: h.time]
    )
  end

  def get_data_between_raw(start_time, end_time) do
    query = """
    SELECT
      ROUND(CAST(MAX(bmp_temp) as NUMERIC), 2) as bmp_temp,
      ROUND(CAST(MAX(sht_temp) as NUMERIC), 2) as sht_temp,
      ROUND(CAST(MAX(humidity) as NUMERIC), 2) as humidity,
      ROUND(CAST(MAX(dewpoint) as NUMERIC), 2) as dewpoint,
      ROUND(CAST(MAX(pressure) as NUMERIC), 2) as pressure,
      ROUND(CAST(SUM(rainfall) as NUMERIC), 2) as rainfall,
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

  def get_month_lows_raw(start_time, end_time) do
    query = """
    SELECT to_char(MIN(iq."timestamp"), 'YYYY-MM-DD') as day_of_month, MIN(iq.bmp_temp) as low_temp from
    (SELECT
      case
        when date_part('hour', "time") < 12 AND date_part('hour', "time") >= 0 then "time" - interval '1 day'
        else null
      end as "timestamp",
      bmp_temp,
      unit_id
        FROM
          history
        WHERE
          "time" >= $1 AND "time" <= $2
    ) iq
    where iq."timestamp" is not NULL
    GROUP by
      iq.unit_id,
      extract(day from iq."timestamp")
      order by day_of_month asc;
    """
    Ecto.Adapters.SQL.query!(Repo, query, [start_time, end_time])
  end

  def get_month_highs_raw(start_time, end_time) do
    query = """
    SELECT to_char(MIN(iq."timestamp"), 'YYYY-MM-DD') as day_of_month, MAX(iq.bmp_temp) as high_temp from
    (SELECT
    case
      when date_part('hour', "time") >= 12 AND date_part('hour', "time") <= 23 then "time"
      else null
      end as "timestamp",
      bmp_temp,
      unit_id
        FROM
          history
        WHERE
          "time" >= $1 AND "time" <= $2
    ) iq
    where iq."timestamp" is not NULL
    GROUP by
      iq.unit_id,
      extract(day from iq."timestamp")
      order by day_of_month asc;
    """
    Ecto.Adapters.SQL.query!(Repo, query, [start_time, end_time])
  end

  def get_latest_conditions() do
    Repo.one(
      from h in History,
      order_by: [desc: h.time],
      limit: 1,
      select: [h.conditions]
    )
  end
end
