defmodule LiveEmailNotification.Repo do
  use Ecto.Repo,
    otp_app: :live_email_notification,
    adapter: Ecto.Adapters.Postgres
end
