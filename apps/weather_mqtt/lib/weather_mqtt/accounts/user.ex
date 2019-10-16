defmodule WeatherMqtt.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email_address, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :hashed_password, :string
    field :active, :boolean
    belongs_to :role, WeatherMqtt.Accounts.Role
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email_address, :active, :role_id])
    |> validate_required([:email_address, :hashed_password, :active])
    |> validate_length(:email_address, min: 3)
    |> assoc_constraint(:role)
    |> unique_constraint(:email_address) # converts unique index in DB into a changeset error
  end

  def changeset_with_password(user, params \\ %{}) do
    user
    |> cast(params, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 5)
    |> validate_confirmation(:password, required: true, message: "passwords do not match")
    |> hash_password()
    |> changeset(params) # uses the regular changest inside the one for passwords
  end

  defp hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:hashed_password, WeatherMqtt.Accounts.Password.hash(password))
  end

  defp hash_password(changeset), do: changeset # matched if password isn't in the list of changes
end
