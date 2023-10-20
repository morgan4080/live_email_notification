defmodule LiveEmailNotification.Db.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    belongs_to :user, LiveEmailNotification.Db.User
    belongs_to :group, LiveEmailNotification.Db.Group
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

  def user_contact_changeset(contact, attrs \\ %{}, opts \\ []) do
    contact
    |> cast(attrs, [:contact_name, :contact_email])
    |> put_assoc(:users, attrs[:user])
    |> validate_email(opts)
    |> validate_name(opts)
  end

  def group_contact_changeset(contact, attrs \\ %{}, opts \\ []) do
    contact
    |> cast(attrs, [:contact_name, :contact_email])
    |> put_assoc(:users, attrs[:group])
    |> validate_email(opts)
    |> validate_name(opts)
  end
end