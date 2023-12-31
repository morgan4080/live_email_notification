defmodule LiveEmailNotification.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :permission_name, :string
      add :permission_description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
