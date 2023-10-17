defmodule LiveEmailNotification.Group do
  use Ecto.Schema

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, LiveEmailNotification.User
    many_to_many :contacts, LiveEmailNotification.Contact, join_through: "groups_contacts"
    many_to_many :emails, LiveEmailNotification.Email, join_through: "groups_emails"
  end
end