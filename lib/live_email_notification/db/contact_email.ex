defmodule LiveEmailNotification.Db.ContactEmail do
  use Ecto.Schema

  import Ecto.Changeset

  schema "contacts_emails" do
    belongs_to :contact, LiveEmailNotification.Db.Contact
    belongs_to :email, LiveEmailNotification.Db.Email
    field :is_email_sent, :boolean, default: false
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def contacts_emails_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_email_sent])
  end
end