defmodule LiveEmailNotification.Db.Role do
  use Ecto.Schema

  import Ecto.Changeset

  schema "roles" do
    field :role_name, :string
    field :role_description, :string

    many_to_many :permissions, LiveEmailNotification.Db.Permission, join_through: "roles_permissions"
    many_to_many :users, LiveEmailNotification.Db.User, join_through: "users_roles"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def plan_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role_name, :role_description])
    |> put_assoc(:users, [:users])
    |> put_assoc(:permissions, [:permissions])
    |> validate_required([:role_name])
  end
end