defmodule LiveEmailNotification.Repo.Migrations.CreateGroupContacts do
  use Ecto.Migration

  # a contact can belong to many groups

  def change do
    create table(:groups_contacts) do
      add :group_id, references(:groups)
      add :contact_id, references(:contacts)
    end

    create unique_index(:groups_contacts, [:group_id, :contact_id])
  end
end
