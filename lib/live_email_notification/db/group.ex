defmodule LiveEmailNotification.Db.Group do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{Contact, User, Email}

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, User
    many_to_many :contacts, Contact, join_through: "group_contact", on_replace: :delete
    many_to_many :emails, Email, join_through: "groups_emails", on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  def group_changeset(group_struct, params \\ %{}, _opts \\ []) do
    group_struct
    |> cast(params, [:group_name, :group_description])
    |> cast_assoc(:contacts, with: &Contact.user_contact_changeset/2)
    |> cast_assoc(:emails, with: &Email.email_changeset/2)
    |> validate_required([:group_name])
  end

  def changeset_update_contacts(group, contacts) do
    group
    |> cast(%{}, [:group_name, :group_description])
    |> put_assoc(:contacts, contacts)
  end
end