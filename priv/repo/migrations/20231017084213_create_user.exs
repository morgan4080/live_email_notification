defmodule LiveEmailNotification.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :uuid, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false, size: 160
      add :msisdn, :string, null: false, size: 160
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :plan_id, references(:plans)
      add :user_type_id, references(:user_types)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email, :msisdn])
  end
end
