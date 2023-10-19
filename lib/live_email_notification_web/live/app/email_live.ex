defmodule LiveEmailNotificationWeb.EmailLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""
      <div class="min-w-7xl">
        <%= if @live_action == :index do %>
          <div>
            <%= @current_path %>
          </div>
        <% end %>
        <%= if @live_action == :user_emails do %>
          <div>
            <%= @current_path %>
          </div>
        <% end %>
      </div>
    """
  end

  def mount(_, _session, socket) do
#    {:ok, assign(socket, page_title: "Email") |> assign(current_path: current_path)}
    IO.inspect( socket.assigns.current_path, label: "EMAIL")
    {:ok, assign(socket, page_title: "Email")}
  end
end
