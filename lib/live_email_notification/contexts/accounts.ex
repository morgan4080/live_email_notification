defmodule LiveEmailNotification.Contexts.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: true

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{User, Role}

  def list_users do
    IO.inspect Repo.all(User)
  end
  
  def get_user!(uid) do
    Repo.get(User, uid)
  end

end
