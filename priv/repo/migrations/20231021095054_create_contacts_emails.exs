defmodule LiveEmailNotification.Repo.Migrations.CreateContactsEmails do
  use Ecto.Migration

  def change do
    create table(:contacts_emails) do
      add :contact_id, references(:contacts, on_delete: :delete_all)
      add :email_id, references(:emails, on_delete: :delete_all)
      add :is_email_sent, :string, null: false, default: false
    end

    create(index(:contacts_emails, [:contact_id]))
    create(index(:contacts_emails, [:email_id]))
  end
end
