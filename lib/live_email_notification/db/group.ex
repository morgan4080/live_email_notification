defmodule LiveEmailNotification.Db.Group do
  use Ecto.Schema

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, LiveEmailNotification.Db.User
    many_to_many :contacts, LiveEmailNotification.Db.Contact, join_through: "groups_contacts"
    many_to_many :emails, LiveEmailNotification.Db.Email, join_through: "groups_emails"
  end
end