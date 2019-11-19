defmodule WeatherBackend.Records.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :name, :string
    timestamps()
  end

  def changeset(unit, params \\ %{}) do
    unit
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
