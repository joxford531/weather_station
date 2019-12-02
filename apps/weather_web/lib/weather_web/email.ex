defmodule WeatherWeb.Email do
  use Bamboo.Phoenix, view: WeatherWeb.EmailView

  def welcome_text_email(email_address) do
    new_email()
    |> to(email_address)
    |> from(Application.get_env(:weather_web, :sending_address))
    |> subject("Welcome!")
    |> text_body("Welcome to JoxyLogic!")
  end

  def activate_account_text(email_address) do
    new_email()
    |> to(email_address)
    |> from(Application.get_env(:weather_web, :sending_address))
    |> subject("JoxyLogic - Activate Your Account")
    |> put_text_layout({WeatherWeb.LayoutView, "email.text"})
    |> render("activate.text")
  end

  def activate_account_email(email_address, token) do
    email_address
    |> activate_account_text()
    |> put_html_layout({WeatherWeb.LayoutView, "email.html"})
    |> render("activate.html", token: token)
  end
end
