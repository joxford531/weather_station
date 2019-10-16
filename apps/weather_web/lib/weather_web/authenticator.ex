defmodule WeatherWeb.Authenticator do
  import Phoenix.Controller
  import Plug.Conn
  require WeatherWeb.Constants
  alias WeatherWeb.Constants
  alias WeatherWeb.Router.Helpers, as: Routes
  alias WeatherMqtt.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user =
      conn
      |> get_session(:user_id)
      |> case do
        nil -> nil
        id -> Accounts.get_user(id)
      end
    assign(conn, :current_user, user)
  end

  def authenticate_user(conn, _opts) do # gets called when used like `plug :authenticate_user when action in [...]`
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def authenticate_admin_user(conn, _opts) do # gets called when used like `plug :authenticate_user when action in [...]`
    if conn.assigns.current_user && conn.assigns.current_user.role_id == Constants.admin_id do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
