defmodule WeatherWeb.Router do
  use WeatherWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WeatherWeb.Authenticator
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WeatherWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/users", UserController, only: [:show, :new, :create]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
  end

  scope "/weather", WeatherWeb do
    pipe_through [:browser, :authenticate_user]

    live "/sensors", Sensors
    live "/top", Top
    live "/history", WeatherDaily
  end

  # Other scopes may use custom stacks.
  # scope "/api", WeatherWeb do
  #   pipe_through :api
  # end
end
