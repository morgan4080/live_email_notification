defmodule LiveEmailNotification.Db.Email do
  use Ecto.Schema

  schema "emails" do
    field :subject, :string
    field :content, :string
    field :date_sent, :utc_datetime

    belongs_to :user, LiveEmailNotification.Db.User
    belongs_to :group, LiveEmailNotification.Db.Group
  end
end