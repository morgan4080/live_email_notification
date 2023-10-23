defmodule LiveEmailNotification.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :description, :string
    end
  end
end
