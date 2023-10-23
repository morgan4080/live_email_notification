defmodule LiveEmailNotification.Db.Permission do
  use Ecto.Schema

  import Ecto.Changeset

  schema "permissions" do
    field :permission_name, :string
    field :permission_description, :string

    many_to_many :roles, LiveEmailNotification.Db.Role, join_through: "roles_permissions"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def permissions_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:permission_name, :permission_description])
    |> validate_required([:permission_name])
  end
end