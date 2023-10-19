defmodule LiveEmailNotificationWeb.RoleLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""
      <%= if @current_path do %>
        <div>
          <%= @current_path %>
        </div>
      <% end %>
    """
  end

  def mount(_, _session, socket) do
    {:ok, assign(socket, page_title: "Role")}
  end
end
