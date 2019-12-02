defmodule WeatherBackend.Repo.Migrations.AddUserActivations do
  use Ecto.Migration

  def change do
    create table(:user_activations, primary_key: false) do
      add :token, :uuid, primary_key: true
      add :generated_at, :utc_datetime, null: false
      add :user_id, references(:users), null: false
      add :redeemed, :boolean, null: false, default: false
    end
  end
end
