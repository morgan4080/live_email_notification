defmodule LiveEmailNotification.Db.Email do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{Contact, User, Group}

  schema "emails" do
    field :subject, :string
    field :content, :string
    field :is_bulk, :boolean, virtual: true, default: false
    belongs_to :user, User
    many_to_many :contacts, Contact, join_through: "contacts_emails", on_replace: :delete
    many_to_many :groups, Group, join_through: "groups_emails", on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  def email_changeset(email, attrs \\ %{}, _opts \\ []) do
    email
    |> cast(attrs, [:subject, :content, :user_id, :is_bulk])
    |> cast_assoc(:contacts, with: &Contact.user_contact_changeset/2)
    |> cast_assoc(:groups, with: &Group.group_changeset/2)
    |> validate_required([:subject, :content])
  end

  def changeset_update_contacts(email, contacts, groups, changes) do
    email
    |> cast(changes, [:subject, :content])
    |> put_assoc(:contacts, contacts)
    |> put_assoc(:groups, groups)
  end
end