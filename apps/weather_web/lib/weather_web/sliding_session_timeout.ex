defmodule WeatherWeb.SlidingSessionTimeout do
  import Plug.Conn

  def init(opts \\ []) do
    Keyword.merge([timeout_after_seconds: 64_800], opts)
  end

  def call(conn, opts) do
    timeout_at = get_session(conn, :session)

    cond do
      timeout_at && now() > timeout_at -> logout_user(conn)
      true -> put_session(conn, :session_timeout_at, new_session_timeout_at(opts[:timeout_after_seconds]))
    end
  end

  defp logout_user(conn) do
    conn
    |> clear_session()
    |> configure_session([:renew])
    |> assign(:session_timeout, true)
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_unix
  end

  defp new_session_timeout_at(additional_seconds) do
    now() + additional_seconds
  end
end
