defmodule LiveEmailNotificationWeb.DashboardLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Contexts.Accounts
  alias LiveEmailNotification.Repo

  def render(assigns) do
    ~H"""
      <div>
        <nav :if={@live_action == :admin} class="flex" aria-label="Breadcrumb">
          <ol role="list" class="flex justify-center">
            <li>
              <div>
                <.link href={~p"/dashboard"}>
                  <Heroicons.Solid.home class="text-gray-500 h-4 w-4" />
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <.link href={~p"/users"} class="text-xs">
                   users
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <.link href={~p"/users/#{@uuid}/dashboard"} class={[
                  "text-xs",
                  @selected_path == "/dashboard" && "border-b border-brand !text-brand"
                ]}>
                  <%=String.split(@selected_path, "/")%>
                </.link>
              </div>
            </li>
          </ol>
        </nav>
        <header>
            <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
              <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
                  <span :if={@live_action == :index}>
                    <.link href={~p"/users/settings"} class="text-brand">
                      <%= @current_user.first_name <> "'s" %>
                    </.link>
                    <%= String.split(@current_path, "/") %>
                  </span>
                  <span :if={@live_action == :admin}>
                    <.link href={~p"/users/settings"} class="text-brand">
                      <%= "User " <> @selected_user.first_name <> "'s" %>
                    </.link>
                    <%= String.split(@selected_path, "/") %>
                  </span>
              </h1>
              <p :if={@live_action == :index} class="text-sm text-slate-500 hover:text-slate-600">On your dashboard you can view a summary of your account</p>
              <p :if={@live_action == :admin} class="text-sm text-slate-500 hover:text-slate-600">On <%=@selected_user.first_name%>'s dashboard you can view a summary of the account. And navigate to other areas of the user's context.</p>
            </div>
        </header>
        <ul class="p-4 sm:px-8 sm:pt-6 sm:pb-8 lg:p-4 xl:px-8 xl:pt-6 xl:pb-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2 gap-8 text-sm leading-6">
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/plan"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={~p"/users/#{@uuid}/plan"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Subscription Plan</dd>
              </div>
              <div>
                <dt class="sr-only">Plan</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400"><%= @current_user.plan.plan_name %></dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/contacts"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={~p"/users/#{@uuid}/contacts"} class="absolute w-full h-full inset-0">

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
                    <span><%= length(@current_user.contacts) %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/groups"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={~p"/users/#{@uuid}/groups"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Groups</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.groups do %>
                    <span><%= length(@current_user.groups) %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/emails"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={~p"/users/#{@uuid}/emails"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Emails</dd>
              </div>
              <div>
                <dt class="sr-only">Contacts Emails</dt>
                <dd class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.emails do %>
                    <span><%= length(@current_user.emails) %></span>
                  <% end %>
                </dd>
              </div>
              </dl>
          </li>
        </ul>
      </div>
    """
  end

  def mount(params, session, socket) do
    IO.inspect(params, label: "PARAMS") # %{"uuid" => "3ca78763-b7c8-4415-a3d0-3b71fa669ad6"}
    IO.inspect(socket.assigns.live_action, label: "LV") # socket.assigns.live_action: :admin
    if socket.assigns.live_action == :admin do
      %{"uuid" => uuid} = params
        socket =
          socket
             |> assign(
                live_action: socket.assigns.live_action,
                page_title: "Dashboard",
                uuid: uuid,
                selected_user: Accounts.get_user_by_uid(uuid) |> Repo.preload([:plan, :user_type, :roles, :groups, :contacts, :role_permissions, :emails]),
                selected_path: "/dashboard"
              )
      {:ok, socket}
    else
      socket =
        socket
        |> assign(
             live_action: socket.assigns.live_action,
             page_title: "Dashboard"
           )
      {:ok, socket}
    end
  end
end
