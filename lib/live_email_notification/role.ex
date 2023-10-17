defmodule LiveEmailNotification.Role do
  use Ecto.Schema

  schema "roles" do
    field :role_name, :string
    field :role_description, :string

    many_to_many :permissions, LiveEmailNotification.Permission, join_through: "roles_permissions"
  end
end