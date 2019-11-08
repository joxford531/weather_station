defmodule WeatherWeb.UserLive.Index do
  use Phoenix.LiveView

  alias WeatherMqtt.Accounts
  alias WeatherMqtt.Accounts.User
  alias WeatherWeb.UserView
  alias WeatherWeb.Router.Helpers, as: Routes

  def render(assigns), do: UserView.render("index.html", assigns)

  def mount(_session, socket) do
    {:ok, assign(socket, page: 1, per_page: 10)}
  end

  def handle_params(params, _url, socket) do
    {page, ""} = Integer.parse(params["page"] || "1")

    {:noreply,
      socket
      |> assign(page: page)
      |> get_users()
    }
  end

  def handle_event("change_active_user", %{"id" => id}, socket) do
    id = String.to_integer(id)
    user = Accounts.get_user(id)
    attrs = %{user | active: !user.active}

    Accounts.update_user(user, Map.from_struct(attrs))

    {:noreply,
     socket
     |> get_users()
    }
  end

  defp get_users(socket) do
    %{page: page, per_page: per_page} = socket.assigns
    assign(socket, users: Accounts.list_users(page, per_page))
  end

end
