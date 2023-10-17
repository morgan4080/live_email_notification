defmodule LiveEmailNotification.Contact do
  use Ecto.Schema

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    belongs_to :user, LiveEmailNotification.User, join_through: "user_contacts"
  end
end