defmodule WeatherWeb.UserController do
  use WeatherWeb, :controller
  require WeatherWeb.Constants
  alias WeatherWeb.Constants
  plug :prevent_unauthorized_access when action in [:show]

  def show(conn, %{"id" => id}) do
    user = WeatherMqtt.get_user(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    user = WeatherMqtt.new_user()
    render(conn, "new.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    case WeatherMqtt.insert_user(user_params) do
      {:ok, user} -> redirect(conn, to: Routes.user_path(conn, :show, user))
      {:error, user} -> render(conn, "new.html", user: user)
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
end
