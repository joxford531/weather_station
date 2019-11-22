defmodule WeatherWeb.UserController do
  use WeatherWeb, :controller
  require WeatherWeb.Constants
  alias WeatherWeb.Constants
  alias WeatherBackend.Accounts
  plug :prevent_unauthorized_access when action in [:show]

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
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

    render(conn, "reset.html", user: changeset)
  end

  def new(conn, _params) do
    user = Accounts.new_user()
    render(conn, "new.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    user =
      Map.put(user_params, "active", false)
      |> Map.put("role_id", Constants.user_id)

    case Accounts.insert_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Your registration has been received and you will be activated after approval")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
      {:error, user} -> render(conn, "new.html", user: user)
    end
  end

  def reset(conn, %{"user" => user_params}) do
    IO.puts("user: #{inspect(user_params)}")

    conn
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
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
end
