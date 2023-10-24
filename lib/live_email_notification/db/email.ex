defmodule LiveEmailNotification.Db.Email do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{Contact, User}

  schema "emails" do
    field :subject, :string
    field :content, :string
    field :is_bulk, :boolean, virtual: true, default: false
    belongs_to :user, User
    many_to_many :contacts, Contact, join_through: "contacts_emails", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def email_changeset(email, attrs \\ %{}, _opts \\ []) do
    email
    |> cast(attrs, [:subject, :content, :user_id, :is_bulk])
    |> cast_assoc(:contacts, with: &Contact.user_contact_changeset/2)
    |> validate_required([:subject, :content])
  end
end