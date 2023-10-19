defmodule LiveEmailNotificationWeb.EmailLive do
  use LiveEmailNotificationWeb, :live_view

#  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""
      <%= if @live_action == :index do %>
        <div>
          <header>
              <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
                <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
                    <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
                </h1>
                <p class="text-sm text-slate-500 hover:text-slate-600">View and add groups to your account.</p>
              </div>
          </header>
        </div>
      <% end %>
      <%= if @live_action == :admin do %>
        <div>
          <%= @live_action %>
        </div>
      <% end %>
    """
  end

  def mount(_, _session, socket) do
#    {:ok, assign(socket, page_title: "Email") |> assign(current_path: current_path)}
    IO.inspect( socket.assigns.current_path, label: "EMAIL")
    {:ok, assign(socket, page_title: "Email")}
  end
end
