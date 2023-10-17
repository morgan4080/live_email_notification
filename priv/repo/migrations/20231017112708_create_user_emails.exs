defmodule LiveEmailNotification.Repo.Migrations.CreateUserEmails do
  use Ecto.Migration

  def change do
    create table(:users_emails) do
      add :user_id, references(:users)
      add :email_id, references(:emails)
    end

    create unique_index(:users_emails, [:user_id, :email_id])
  end
end
