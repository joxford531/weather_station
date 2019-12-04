defmodule WeatherWeb.UserController do
  use WeatherWeb, :controller
  require Logger
  require WeatherWeb.Constants
  alias WeatherWeb.Constants
  alias WeatherBackend.Accounts

  plug :prevent_unauthorized_access when action in [:show]

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def show_activation(conn, %{"token" => token}) do
    activation = Accounts.get_user_activation(token)

    if is_nil(activation) do
      render_not_found(conn)
    end

    with {:ok, _} <- Accounts.update_user(activation.user, %{active: true}),
      {:ok, _} <- Accounts.update_user_activation(activation, %{redeemed: true})
    do
      conn
      |> put_flash(:info, "Success! You are now activated and can login")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()

    else
      {:error, error} ->
        Logger.error("Error looking up token: #{token}")
        Logger.error("#{inspect(error)}")
        render_not_found(conn)
    end
  end

  def show_password_reset(conn, %{"token" => token}) do
    reset_token = Accounts.get_reset_token(token)

    if is_nil(reset_token) do
      conn
      |> put_status(:not_found)
      |> put_view(WeatherWeb.ErrorView)
      |> render("404.html")
    end

    changeset = Accounts.change_user(reset_token.user)

    render(conn, "reset.html", user: changeset, token: token)
  end

  def show_remove(conn, %{"token" => token}) do
    remove_token = Accounts.get_remove_token(token)

    if is_nil(remove_token) do
      conn
      |> put_status(:not_found)
      |> put_view(WeatherWeb.ErrorView)
      |> render("404.html")
    end

    changeset = Accounts.change_user(remove_token.user)

    render(conn, "remove.html", user: changeset)
  end

  def new(conn, _params) do
    user = Accounts.new_user()
    render(conn, "new.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    user =
      Map.put(user_params, "active", false)
      |> Map.put("role_id", Constants.user_id)

    with {:ok, user} <- Accounts.insert_user(user),
      {:ok, activation} <- Accounts.insert_user_activation(
        %{user_id: user.id, redeemed: false, generated_at: DateTime.utc_now()}
      ) do

        WeatherWeb.Email.activate_account_email(user.email_address, activation.token)
        |> WeatherWeb.Mailer.deliver_now()

        conn
        |> put_flash(:info, "Success! Please check your email to activate your account")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
      else
        {:error, user} ->
          render(conn, "new.html", user: user)
    end
  end

  def reset(conn, %{"token" => token, "user" => user_params}) do

    user = Accounts.get_password_reset_user!(token)

    case Accounts.update_user_password(user, user_params) do
      {:ok, _user} ->
        # ensure token is properly deleted first
        {1, nil} = Accounts.delete_reset_token(token)

        conn
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "reset.html", user: changeset, token: token)
    end
  end

  defp prevent_unauthorized_access(conn, _opts) do
    current_user = Map.get(conn.assigns, :current_user)

    requested_user_id =
      conn.params
      |> Map.get("id")
      |> String.to_integer()

    if is_nil(current_user) || ((current_user.id != requested_user_id) && (current_user.role_id != Constants.admin_id)) do
      conn
      |> put_flash(:error, "You do not have authorization to see this page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  defp render_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(WeatherWeb.ErrorView)
    |> render("404.html")
  end
end
