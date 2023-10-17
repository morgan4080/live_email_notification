defmodule LiveEmailNotification.Db.Contact do
  use Ecto.Schema

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    many_to_many :users, LiveEmailNotification.Db.User, join_through: "users_contacts"
    many_to_many :groups, LiveEmailNotification.Db.Group, join_through: "users_groups"
  end
end