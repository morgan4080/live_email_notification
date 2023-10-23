defmodule LiveEmailNotification.Db.UserType do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.User

  schema "user_types" do
    field :user_type, :string

    has_many :users, User, on_delete: :delete_all, on_replace: :delete
  end

  def plan_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_type,])
    |> validate_required([:user_type])
  end
end