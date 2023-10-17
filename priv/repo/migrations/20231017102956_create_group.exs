defmodule LiveEmailNotification.Repo.Migrations.CreateGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :group_name, :string
      add :group_description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
