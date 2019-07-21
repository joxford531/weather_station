defmodule WeatherWeb.PageController do
  use WeatherWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
