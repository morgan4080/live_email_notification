defmodule LiveEmailNotification.Repo.Migrations.CreateUserContacts do
  use Ecto.Migration

  def change do
    create table(:users_contacts) do
      add :user_id, references(:users)
      add :contact_id, references(:contacts)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users_contacts, [:user_id, :contact_id])
  end
end
