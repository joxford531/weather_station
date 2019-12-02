defmodule WeatherBackend.Repo.Migrations.AddRedeemedToPasswordresets do
  use Ecto.Migration

  def change do
    alter table(:password_resets) do
      add :redeemed, :boolean, null: false, default: false
    end
  end
end
