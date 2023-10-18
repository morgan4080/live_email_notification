defmodule LiveEmailNotificationWeb.Components do
  use Phoenix.Component

  import LiveEmailNotificationWeb.CoreComponents

  embed_templates "custom/*"

  def user_table(assigns) do
    ~H"""
      <.header class="text-left">
        Users
        <:subtitle>
          All Users.
        </:subtitle>
       </.header>
      <.custom_table />
    """
  end
end