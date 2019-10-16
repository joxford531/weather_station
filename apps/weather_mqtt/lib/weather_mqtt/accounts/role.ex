defmodule WeatherMqtt.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "roles" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  # this returns a query that can be used in lots of context functions to prevent rewriting the same order clause
  def alphabetical(query) do
    from c in query, order_by: c.name
  end
end
