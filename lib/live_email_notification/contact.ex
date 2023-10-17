defmodule LiveEmailNotification.Contact do
  use Ecto.Schema

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string
  end
end