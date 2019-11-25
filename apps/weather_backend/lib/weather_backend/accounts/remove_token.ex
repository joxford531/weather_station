defmodule WeatherBackend.Accounts.RemoveToken do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:token, :binary_id, autogenerate: true}
  schema "remove_tokens" do
    field :generated_at, :utc_datetime
    belongs_to :user, WeatherBackend.Accounts.User
  end

  def changeset(history, params \\ %{}) do
    history
    |> cast(params, [:generated_at, :user_id])
    |> validate_required([:generated_at, :user_id])
    |> assoc_constraint(:user)
  end
end
