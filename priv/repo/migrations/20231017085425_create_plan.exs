defmodule LiveEmailNotification.Repo.Migrations.CreatePlan do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :plan_name, :string
      add :plan_description, :string
    end
  end
end
