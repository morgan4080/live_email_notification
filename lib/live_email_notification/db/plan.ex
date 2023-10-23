defmodule LiveEmailNotification.Db.Plan do
  use Ecto.Schema

  import Ecto.Changeset

  schema "plans" do
    field :plan_name, :string
    field :price, :float
    field :plan_description, :string

    has_many :users, LiveEmailNotification.Db.User, on_delete: :delete_all, on_replace: :delete
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def plan_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:plan_name, :price, :plan_description])
    |> validate_required([:plan_name, :price])
  end
end