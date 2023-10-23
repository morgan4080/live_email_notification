defmodule LiveEmailNotificationWeb.EmailLive do
  use LiveEmailNotificationWeb, :live_view

  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
            <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
            <button phx-click="showAddGroup" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center text-xs">Create <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
            </button>
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">View and send emails.</p>
        </div>
        <.table id="emails" rows={@current_user.emails} callback={JS.push("showAddGroup", value: %{"context" => "add"})}>
          <:col :let={email} label="Subject"><%= email.inserted_at %></:col>
          <:col :let={email} label="Date Sent"><%= email.date_sent %></:col>
          <:col :let={email} label="Status"><%= email.date_sent %></:col>
          <:col :let={email} label="Created"><%= email.inserted_at %></:col>
          <:col :let={email} label="Actions">
            <span class="space-x-1">
              <button phx-click="showModal" phx-value-selected={email.id} phx-value-context="email" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Email</span>
                <dl>
                  <dt class="sr-only">View email</dt>
                  <dd>
                    <Heroicons.Outline.eye class="text-teal-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={email.id} phx-value-context="edit" type="button" class="border bg-zinc-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Edit</span>
                <dl>
                  <dt class="sr-only">Edit email</dt>
                  <dd>
                    <Heroicons.Outline.pencil class="text-zinc-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={email.id} phx-value-context="delete" type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Delete</span>
                <dl>
                  <dt class="sr-only">Delete email</dt>
                  <dd>
                    <Heroicons.Outline.trash class="text-red-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
            </span>
          </:col>
        </.table>
        <.dialogue
          :if={@modal_active}
          id="email-dialogue"
          show
          on_cancel={JS.navigate(~p"/emails")}
          class={[@modal_context == "delete" && "!p-1"]}
        >
        </.dialogue>
      </div>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
           trigger_submit: false,
           check_errors: false,
           modal_active: Map.has_key?(params, "action"),
           modal_context: Map.get(params, "action"),
           custom_error: nil,
           selected_email: nil,
           page_title: "Emails"
         )
    {:ok, socket}
  end

  def handle_event("showAddGroup", %{ "context" => context }, socket) do
    modal_active = !socket.assigns.modal_active
    socket = socket
             |> assign(:modal_active, modal_active)
             |> assign(:modal_context, context)
    {:noreply, socket}
  end
end
