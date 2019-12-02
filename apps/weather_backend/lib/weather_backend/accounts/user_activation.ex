defmodule WeatherBackend.Accounts.UserActivation do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:token, :binary_id, autogenerate: true}
  schema "user_activations" do
    field :generated_at, :utc_datetime
    field :redeemed, :boolean
    belongs_to :user, WeatherBackend.Accounts.User
  end

  def changeset(history, params \\ %{}) do
    history
    |> cast(params, [:generated_at, :user_id, :redeemed])
    |> validate_required([:generated_at, :user_id, :redeemed])
    |> assoc_constraint(:user)
  end
end
