defmodule LiveEmailNotification.User do
  use Ecto.Schema

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :msisdn, :string
    field :is_super, :boolean
    field :password_hash, :string

    belongs_to :plan, LiveEmailNotification.Plan
    many_to_many :roles, LiveEmailNotification.Role, join_through: "users_roles"
    has_many :contacts, LiveEmailNotification.Contact, join_through: "user_contacts"
    has_many :groups, LiveEmailNotification.Group, join_through: "user_groups"
  end
end