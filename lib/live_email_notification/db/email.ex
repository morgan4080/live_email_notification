defmodule LiveEmailNotification.Db.Email do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{Contact}

  schema "emails" do
    field :subject, :string
    field :content, :string

    many_to_many :contacts, Contact, join_through: "contacts_emails", on_replace: :delete
  end

  def email_changeset(email_struct, attrs \\ %{}, opts \\ []) do
    email_struct
    |> cast(attrs, [:subject, :content])
    |> cast_assoc(:contacts, with: &Contact.user_contact_changeset/2)
    |> validate_required([:subject, :content])
  end
end