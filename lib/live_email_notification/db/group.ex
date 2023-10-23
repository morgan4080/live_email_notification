defmodule LiveEmailNotification.Db.Group do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{Contact, User}

  schema "groups" do
    field :group_name, :string
    field :group_description, :string

    belongs_to :user, User
    many_to_many :contacts, Contact, join_through: "groups_contacts"
    timestamps(type: :utc_datetime)
  end

  def group_changeset(group_struct, params \\ %{}, opts \\ []) do
    IO.inspect(group_struct, label: "group_struct")

    group_struct
    |> cast(params, [:group_name, :group_description])
    |> cast_assoc(:contacts, with: &Contact.user_contact_changeset/2)
    |> validate_required([:group_name])
  end
end