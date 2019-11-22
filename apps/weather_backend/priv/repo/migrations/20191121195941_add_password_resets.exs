defmodule WeatherBackend.Repo.Migrations.AddPasswordResets do
  use Ecto.Migration

  def change do
    create table(:password_resets, primary_key: false) do
      add :token, :uuid, primary_key: true
      add :generated_at, :utc_datetime, null: false
      add :user_id, references(:users), null: false

    end
  end
end
