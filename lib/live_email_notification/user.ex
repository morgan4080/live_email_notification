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
  end
end