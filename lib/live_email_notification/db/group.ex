defmodule LiveEmailNotification.Db.Group do
  use Ecto.Schema

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, LiveEmailNotification.Db.User
    has_many :contacts, LiveEmailNotification.Db.Contact, on_delete: :delete_all, on_replace: :delete
    has_many :emails, LiveEmailNotification.Db.Email, on_delete: :delete_all, on_replace: :delete
  end
end