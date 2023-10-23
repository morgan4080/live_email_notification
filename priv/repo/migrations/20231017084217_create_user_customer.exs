defmodule LiveEmailNotification.Repo.Migrations.CreateUserCustomer do
  use Ecto.Migration

  def change do
    create table(:user_customer, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :customer_id, references(:customers, on_delete: :delete_all), primary_key: true
    end

    create(index(:user_customer, [:user_id]))
    create(index(:user_customer, [:customer_id]))
  end
end
