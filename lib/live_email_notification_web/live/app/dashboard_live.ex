defmodule LiveEmailNotificationWeb.DashboardLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Contexts.Accounts
  alias LiveEmailNotification.Repo

  def render(assigns) do
    ~H"""
      <div>
        <nav :if={@live_action == :admin} class="flex px-4 sm:px-6 lg:px-8" aria-label="Breadcrumb">
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
                <.link href={~p"/admin/users"} class="text-xs">
                   users
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <.link href={"/admin/users/#{@uuid}/dashboard"} class={[
                  "text-xs",
                  @selected_path == "/dashboard" && "border-b border-brand !text-brand"
                ]}>
                  <%=String.split(@selected_path, "/")%>: <%=@selected_user.email%>
                </.link>
              </div>
            </li>
          </ol>
        </nav>
        <header>
            <div class="mx-auto px-4 py-6 sm:px-6 space-y-1 lg:px-8">
              <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
                  <span :if={@live_action == :index}>
                    <.link href={~p"/users/settings"} class="text-brand">
                      <%= @current_user.first_name <> "'s" %>
                    </.link>
                    <%= String.split(@current_path, "/") %>
                  </span>
                  <span :if={@live_action == :admin}>
                    Dashboard
                  </span>
              </h1>
              <p :if={@live_action == :index} class="text-sm text-slate-500 hover:text-slate-600">On your dashboard you can view a summary of your account</p>
              <p :if={@live_action == :admin} class="text-sm text-slate-500 hover:text-slate-600">On user: <%=@selected_user.email%> dashboard you can view a summary of the account. And navigate to other areas of the user's context.</p>
            </div>
        </header>
        <ul class="p-4 sm:px-8 sm:pt-6 sm:pb-8 lg:p-4 xl:px-8 xl:pt-6 xl:pb-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-1 xl:grid-cols-2 gap-8 text-sm leading-6">
          <li class="relative group cursor-not-allowed rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Subscription Plan</dd>
              </div>
              <div>
                <dt class="sr-only">Plan</dt>
                <dd :if={@live_action == :index} class="group-hover:text-blue-200 text-zinc-400"><%= @current_user.plan.plan_name %></dd>
                <dd :if={@live_action == :admin} class="group-hover:text-blue-200 text-zinc-400"><%= @selected_user.plan.plan_name %></dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/contacts"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={"/admin/users/#{@uuid}/contacts"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Contacts</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd :if={@live_action == :index} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.contacts do %>
                    <span><%= length(@current_user.contacts) %></span>
                  <% end %>
                </dd>
                <dd :if={@live_action == :admin} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @selected_user.contacts do %>
                    <span><%= length(@selected_user.contacts) %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/groups"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={"/admin/users/#{@uuid}/groups"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Groups</dd>
              </div>
              <div>
                <dt class="sr-only">Category</dt>
                <dd :if={@live_action == :index} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.groups do %>
                    <span><%= length(@current_user.groups) %></span>
                  <% end %>
                </dd>
                <dd :if={@live_action == :admin} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @selected_user.groups do %>
                    <span><%= length(@selected_user.groups) %></span>
                  <% end %>
                </dd>
              </div>
            </dl>
          </li>
          <li class="relative group cursor-pointer rounded-md p-3 bg-white ring-1 ring-slate-200 shadow-sm hover:bg-brand hover:ring-brand hover:shadow-md">
            <.link :if={@live_action == :index} href={~p"/emails"} class="absolute w-full h-full inset-0">

            </.link>
            <.link :if={@live_action == :admin} href={~p"/admin/users/" <> @uuid <> "/emails"} class="absolute w-full h-full inset-0">

            </.link>
            <dl class="grid sm:block lg:grid xl:block grid-cols-2 grid-rows-2 items-center">
              <div>
                <dt class="sr-only">Title</dt>
                <dd class="font-semibold text-slate-900 group-hover:text-white">Emails</dd>
              </div>
              <div>
                <dt class="sr-only">Contacts Emails</dt>
                <dd :if={@live_action == :index} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @current_user.emails do %>
                    <span><%= length(@current_user.emails) %></span>
                  <% end %>
                </dd>
                <dd :if={@live_action == :admin} class="group-hover:text-blue-200 text-zinc-400">
                  <%= if @selected_user.emails do %>
                    <span><%= length(@selected_user.emails) %></span>
                  <% end %>
                </dd>
              </div>
              </dl>
          </li>
        </ul>
      </div>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
           live_action: socket.assigns.live_action,
           page_title: "Dashboard",
           selected_path: "/dashboard"
         )
    {:ok, socket}
  end

end
