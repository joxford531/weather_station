defmodule WeatherBackend.Repo.Migrations.AddLastloginToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_login, :utc_datetime
    end
  end
end
