defmodule LiveEmailNotification.Contact do
  use Ecto.Schema

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    many_to_many :users, LiveEmailNotification.User, join_through: "users_contacts"
  end
end