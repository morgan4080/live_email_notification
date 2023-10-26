defmodule LiveEmailNotification.Repo.Migrations.CreateGroupEmails do
  use Ecto.Migration

  def change do
    create table(:groups_emails) do
      add :group_id, references(:groups, on_delete: :delete_all)
      add :email_id, references(:emails, on_delete: :delete_all)
    end

    create(index(:groups_emails, [:group_id]))
    create(index(:groups_emails, [:email_id]))
  end
end
