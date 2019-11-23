defmodule WeatherWeb.Email do
  use Bamboo.Phoenix, view: WeatherWeb.EmailView

  def welcome_text_email(email_address) do
    new_email()
    |> to(email_address)
    |> from(Application.get_env(:weather_web, :sending_address))
    |> subject("Welcome!")
    |> text_body("Welcome to JoxyLogic!")
  end
end
