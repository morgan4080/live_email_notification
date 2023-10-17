defmodule LiveEmailNotification.Repo.Migrations.CreateUserContacts do
  use Ecto.Migration

  def change do
    create table(:user_contacts) do
      add :user_id, references(:users)
      add :contact_id, references(:contacts)
    end

    create unique_index(:user_contacts, [:user_id, :contact_id])
  end
end
