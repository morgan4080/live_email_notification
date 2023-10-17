defmodule LiveEmailNotification.Repo.Migrations.UserBelongsToPlan do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :plan_id, references(:plans)
    end
  end
end
