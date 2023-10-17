defmodule LiveEmailNotification.Permission do
  use Ecto.Schema

  schema "permissions" do
    field :permission_name, :string
    field :permission_description, :string

    many_to_many :roles, LiveEmailNotification.Role, join_through: "roles_permissions"
  end
end