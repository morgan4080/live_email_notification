defmodule LiveEmailNotificationWeb.GroupLive do
  use LiveEmailNotificationWeb, :live_view

#  alias LiveEmailNotification.Contexts.Accounts

  def render(assigns) do
    ~H"""
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
    """
  end

  def mount(_, _session, socket) do
    IO.inspect( socket.assigns.current_path, label: "GROUP")
    {:ok, assign(socket, page_title: "Group")}
  end
end
