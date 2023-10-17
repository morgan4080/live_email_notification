defmodule LiveEmailNotification.Repo.Migrations.CreateContact do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :contact_name, string
      add :contact_email, string
    end
  end
end
