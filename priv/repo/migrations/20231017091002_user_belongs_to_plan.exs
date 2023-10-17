defmodule LiveEmailNotification.Repo.Migrations.UserBelongsToPlan do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :plan_id, references(:plans)
    end
  end
end
