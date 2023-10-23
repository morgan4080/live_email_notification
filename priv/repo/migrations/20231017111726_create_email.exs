defmodule LiveEmailNotification.Repo.Migrations.CreateEmail do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :subject, :string
      add :content, :string

      timestamps(type: :utc_datetime)
    end
  end
end
