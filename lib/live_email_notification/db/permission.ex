defmodule LiveEmailNotification.Db.Permission do
  use Ecto.Schema

  schema "permissions" do
    field :permission_name, :string
    field :permission_description, :string

    many_to_many :roles, LiveEmailNotification.Db.Role, join_through: "roles_permissions"
  end
end