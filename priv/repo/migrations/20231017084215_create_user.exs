defmodule LiveEmailNotification.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string
      add :first_name, :string
      add :last_name, :string
      add :email_address, :string
      add :msisdn, :string
      add :is_super, :boolean
      add :password_hash, :string

      timestamps()
    end
  end
end
