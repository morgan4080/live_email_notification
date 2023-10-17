defmodule LiveEmailNotification.Repo.Migrations.CreateUserGroups do
  use Ecto.Migration

  def change do
    create table(:user_groups) do
      add :user_id, references(:users)
      add :group_id, references(:groups)
    end

    create unique_index(:user_groups, [:user_id, :group_id])
  end
end
