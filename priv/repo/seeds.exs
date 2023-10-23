# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LiveEmailNotification.Repo.insert!(%LiveEmailNotification.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias LiveEmailNotification.Db.Plan
alias LiveEmailNotification.Repo

Repo.insert! %Plan{
  plan_name: "Basic",
  price: 200.0,
  plan_description: "All users have this plan"
}


Repo.insert! %Plan{
  plan_name: "Bronze",
  price: 500.0,
  plan_description: "Better plan"
}


Repo.insert! %Plan{
  plan_name: "Silver",
  price: 800.0,
  plan_description: "Good plan"
}


Repo.insert! %Plan{
  plan_name: "Gold",
  price: 1000.0,
  plan_description: "Best plan"
}
