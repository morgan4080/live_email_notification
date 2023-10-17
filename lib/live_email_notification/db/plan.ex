defmodule LiveEmailNotification.Db.Plan do
  use Ecto.Schema

  schema "plans" do
    field :plan_name, :string
    field :plan_description, :string

    has_many :users, LiveEmailNotification.Db.User
  end
end