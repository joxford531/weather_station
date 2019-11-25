defmodule WeatherBackend.Accounts do
  import Ecto.Query, warn: false
  alias WeatherBackend.Repo

  alias WeatherBackend.Accounts.{Role, User, Password, PasswordReset, RemoveToken}

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user) do
    user
    |> User.changeset_with_password()
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
    with user when not is_nil(user) <- Repo.get_by(User, %{email_address: email, active: true}),
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

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_password(%User{} = user, attrs) do
    user
    |> User.changeset_with_password(attrs)
    |> Repo.update()
  end

  def insert_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def insert_password_reset(attrs) do
    %PasswordReset{}
    |> PasswordReset.changeset(attrs)
    |> Repo.insert()
  end

  def get_reset_token(token) do
    case Ecto.UUID.dump(token) do
      {:ok, _uuid} ->
        Repo.get(PasswordReset, token)
        |> Repo.preload(:user)
      :error -> nil
    end
  end

  def insert_remove_token(attrs) do
    %RemoveToken{}
    |> RemoveToken.changeset(attrs)
    |> Repo.insert()
  end

  def get_remove_token(token) do
    case Ecto.UUID.dump(token) do
      {:ok, _uuid} ->
        Repo.get(RemoveToken, token)
        |> Repo.preload(:user)
      :error -> nil
    end
  end
end
