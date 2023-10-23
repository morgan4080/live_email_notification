defmodule LiveEmailNotification.Repo.Migrations.CreateGroupContacts do
  use Ecto.Migration

  # a contact can belong to many groups

  def change do
    create table(:group_contact, primary_key: false) do
      add :group_id, references(:groups, on_delete: :delete_all), primary_key: true
      add :contact_id, references(:contacts, on_delete: :delete_all), primary_key: true
    end

    create(index(:group_contact, [:group_id]))
    create(index(:group_contact, [:contact_id]))
  end
end
