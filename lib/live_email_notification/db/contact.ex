defmodule LiveEmailNotification.Db.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts"  do
    field :contact_name, :string
    field :contact_email, :string

    belongs_to :user, LiveEmailNotification.Db.User
    many_to_many :groups, LiveEmailNotification.Db.Group, join_through: "groups_contacts"
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
    |> cast(attrs, [:contact_name, :contact_email, :user_id])
    |> validate_email(opts)
    |> validate_name(opts)
  end

  def group_contact_changeset(contact, attrs \\ %{}, opts \\ []) do
    # needs put_assoc group
    contact
    |> cast(attrs, [:contact_name, :contact_email])
    |> put_assoc(:groups, [:groups])
    |> validate_email(opts)
    |> validate_name(opts)
  end
end