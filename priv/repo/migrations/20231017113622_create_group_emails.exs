defmodule LiveEmailNotification.Repo.Migrations.CreateGroupEmails do
  use Ecto.Migration

  def change do
    create table(:groups_emails) do
      add :group_id, references(:groups)
      add :email_id, references(:emails)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:groups_emails, [:group_id, :email_id])
  end
end
