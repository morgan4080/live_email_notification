defmodule LiveEmailNotification.Db.GroupEmail do
  use Ecto.Schema

  import Ecto.Changeset

  schema "groups_emails" do
    belongs_to :group, LiveEmailNotification.Db.Group
    belongs_to :email, LiveEmailNotification.Db.Email
  end
end