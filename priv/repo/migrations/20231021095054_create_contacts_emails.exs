defmodule LiveEmailNotification.Repo.Migrations.CreateContactsEmails do
  use Ecto.Migration

  def change do
    create table(:contacts_emails) do
      add :contact_id, references(:contacts)
      add :email_id, references(:emails)
      add :is_email_sent, :string, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:contacts_emails, [:contact_id, :email_id])
  end
end
