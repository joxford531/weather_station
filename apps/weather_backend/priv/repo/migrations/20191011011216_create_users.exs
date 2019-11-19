defmodule WeatherBackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email_address, :string, null: false
      add :hashed_password, :string, null: false
      add :active, :boolean, null: false
      add :role_id, references(:roles), null: false

      timestamps()
    end

    create unique_index(:users, [:email_address])
  end
end
