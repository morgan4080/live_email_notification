defmodule LiveEmailNotification.Plan do
  use Ecto.Schema

  schema "plans" do
    field :plan_name, :string
    field :plan_description, :string

    has_many :users, LiveEmailNotification.User
  end
end