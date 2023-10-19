defmodule LiveEmailNotificationWeb.GroupLive do
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
    IO.inspect( socket.assigns.current_path, label: "GROUP")
    {:ok, assign(socket, page_title: "Group")}
  end
end
