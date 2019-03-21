defmodule AuthWeb.SendEmailController do
  use AuthWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def send_email(conn, %{"email" => email}) do
    Auth.Email.send_test_email_2(email, "Email to me", "www.example_link.com")
    |> Auth.Mailer.deliver_now()

    render(conn, "index.html")
  end
end
