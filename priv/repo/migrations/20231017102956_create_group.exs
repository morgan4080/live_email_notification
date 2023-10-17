defmodule LiveEmailNotification.Repo.Migrations.CreateGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :group_name, :string
      add :group_description, :string
    end
  end
end
