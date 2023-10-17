defmodule LiveEmailNotification.Db.User do
  use Ecto.Schema

  schema "users" do
    field :uuid, Ecto.UUID
    field :first_name, :string
    field :last_name, :string
    field :email_address, :string
    field :msisdn, :string
    field :is_super, :boolean
    field :password_hash, :string

    belongs_to :plan, LiveEmailNotification.Db.Plan
    many_to_many :roles, LiveEmailNotification.Db.Role, join_through: "users_roles"
    many_to_many :contacts, LiveEmailNotification.Db.Contact, join_through: "users_contacts"
    has_many :groups, LiveEmailNotification.Db.Group
    many_to_many :emails, LiveEmailNotification.Db.Email, join_through: "users_emails"
  end
end