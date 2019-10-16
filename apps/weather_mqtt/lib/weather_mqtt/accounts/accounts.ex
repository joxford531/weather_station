defmodule WeatherMqtt.Accounts do
  import Ecto.Query, warn: false
  alias WeatherMqtt.Repo

  alias WeatherMqtt.Accounts.{Role, User, Password}

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def insert_user(params) do
    %User{}
    |> User.changeset_with_password(params)
    |> Repo.insert()
  end

  def get_user(id) do
    Repo.get!(User, id)
    |> Repo.preload(:role)
  end

  def get_user_by_email_and_password(email, password) do
    with user when not is_nil(user) <- Repo.get_by(User, %{email_address: email}),
      true <- Password.verify_with_hash(password, user.hashed_password) do
        user
        |> Repo.preload(:role)
    else
    _ -> Password.dummy_verify()
    end
  end

  def list_users(current_page, per_page) do
    Repo.all(
      from u in User,
      order_by: [asc: u.id],
      offset: ^((current_page - 1) * per_page),
      limit: ^per_page,
      preload: [:role]
    )
  end

  def new_user(), do: User.changeset_with_password(%User{})

  def insert_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end
end
