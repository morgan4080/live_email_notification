defmodule LiveEmailNotificationWeb.DashboardLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""

    """
  end

  def mount(_, _session, socket) do
    {:ok, assign(socket, page_title: "Dashboard")}
  end
end
