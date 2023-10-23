defmodule LiveEmailNotification.Db.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiveEmailNotification.Db.{User, Group, Email}

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    belongs_to :user, User
    many_to_many :groups, Group, join_through: "groups_contacts", on_replace: :delete
    many_to_many :emails, Email, join_through: "contacts_emails", on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  def validate_email(changeset, _opts) do
    changeset
    |> validate_required([:contact_email])
    |> validate_format(:contact_email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:contact_email, max: 160)
  end

  def validate_name(changeset, _opts) do
    changeset
    |> validate_required([:contact_name])
  end

  def user_contact_changeset(contact_struct, attrs \\ %{}, opts \\ []) do
    contact_struct
    |> cast(attrs, [:contact_name, :contact_email, :user_id])
    |> validate_email(opts)
    |> validate_name(opts)
    |> cast_assoc(:groups, with: &Group.group_changeset/2)
    |> cast_assoc(:emails, with: &Email.email_changeset/2)
  end

  def user_contact_update_changeset(contact_struct, attrs \\ %{}, opts \\ []) do
    contact_struct
    |> cast(attrs, [:contact_name, :contact_email, :user_id])
    |> validate_email(opts)
    |> validate_name(opts)
    |> cast_assoc(:groups, with: &Group.group_changeset/2)
    |> cast_assoc(:emails, with: &Email.email_changeset/2)
  end
end