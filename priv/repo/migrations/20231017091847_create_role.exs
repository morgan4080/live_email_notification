defmodule LiveEmailNotification.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :role_name, :string
      add :role_description, :string

      timestamps()
    end
  end
end
