defmodule LiveEmailNotificationWeb.PlanLive do
  use LiveEmailNotificationWeb, :live_view

#  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""
      <%= if @current_path do %>
        <div>
          <%= @current_path %>
        </div>
      <% end %>
    """
  end

  # load uuid users plan
  # load current users plan
  # load all available plans

  def mount(_, _session, socket) do
    {:ok, assign(socket, page_title: "Plan")}
  end
end
