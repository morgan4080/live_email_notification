defmodule LiveEmailNotification.Email do
  use Ecto.Schema

  schema "emails" do
    field :subject, :string
    field :content, :string
    field :date_sent, :utc_datetime

    many_to_many :users, LiveEmailNotification.User, join_through: "users_emails"
  end
end