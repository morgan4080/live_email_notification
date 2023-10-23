defmodule LiveEmailNotification.Repo.Migrations.CreateUserTypes do
  use Ecto.Migration

  def change do
    create table(:user_types) do
      add :user_type, :string
    end
  end
end
