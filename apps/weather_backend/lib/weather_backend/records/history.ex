defmodule WeatherBackend.Records.History do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key false
  schema "history" do
    field :time, :utc_datetime
    field :timezone, :string
    field :bmp_temp, :float
    field :sht_temp, :float
    field :humidity, :float
    field :dewpoint, :float
    field :pressure, :float
    field :conditions, :string
    field :rainfall, :float
    belongs_to :unit, WeatherBackend.Records.Unit
  end

  def changeset(history, params \\ %{}) do
    history
    |> cast(params, [:time, :timezone, :bmp_temp, :sht_temp, :humidity, :dewpoint, :pressure, :conditions, :rainfall, :unit_id])
    |> validate_required([:time, :timezone, :bmp_temp, :sht_temp, :humidity, :dewpoint, :pressure, :conditions, :rainfall])
    |> assoc_constraint(:unit)
    |> unique_constraint(:time)
    |> validate_change(:time, &validate/2)
  end

  defp validate(:time, ends_at_date) do
    case DateTime.compare(ends_at_date, DateTime.utc_now()) do
      :gt -> [time: "time cannot be in the future"]
      _ -> [] # empty changeset errors
    end
  end
end
