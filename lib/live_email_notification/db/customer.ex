defmodule LiveEmailNotification.Db.Customer do
  use Ecto.Schema

  import Ecto.Changeset
  alias LiveEmailNotification.Db.{User}

  schema "customer" do
    field :description, :string
    many_to_many :users, User, join_through: "user_customer", on_replace: :delete
  end

  def customer_changeset(customer, params \\ %{}) do
    customer
    |> cast(params, [:description])
    |> cast_assoc(:users, with: &User.user_changeset/2)
  end

  def changeset_update_users(customer, users) do
    customer
    |> cast(%{}, [:description])
    |> put_assoc(:users, users)
  end
end