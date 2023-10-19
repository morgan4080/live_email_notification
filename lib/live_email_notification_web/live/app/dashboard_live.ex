defmodule LiveEmailNotificationWeb.DashboardLive do
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
              <p class="text-sm text-slate-500 hover:text-slate-600">On your dashboard you can view a summary of your account</p>
            </div>
        </header>
        <ul class="p-4 sm:px-8 sm:pt-6 sm:pb-8 lg:p-4 xl:px-8 xl:pt-6 xl:pb-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2 gap-8 text-sm leading-6">
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link href={~p"/paywall"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Subscription Plan</dd>
              </div>
              <div>
                <dt class="sr-only">Plan</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400"><%= @current_user.plan %></dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link href={~p"/contacts"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Contacts</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.contacts do %>
                    <span><%= @current_user.contacts %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link href={~p"/groups"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Groups</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.contacts do %>
                    <span><%= @current_user.groups %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link href={~p"/emails"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Emails</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.emails do %>
                    <span><%= @current_user.groups %></span>
                  <% end %>
                </dd>
              </div>
              </dl>
          </li>
        </ul>
      </div>
    """
  end

  def mount(_, _session, socket) do
    {:ok, assign(socket, page_title: "Dashboard")}
  end
end
