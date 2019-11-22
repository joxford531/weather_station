defmodule WeatherWeb.Email do
  use Bamboo.Phoenix, view: WeatherWeb.EmailView

  def welcome_text_email(email_address) do
    new_email()
    |> to(email_address)
    |> from("joxford531@gmail.com")
    |> subject("Welcome!")
    |> text_body("Welcome to JoxyLogic!")
  end
end
