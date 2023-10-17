defmodule LiveEmailNotification.Group do
  use Ecto.Schema

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, LiveEmailNotification.User, join_through: "user_groups"
  end
end