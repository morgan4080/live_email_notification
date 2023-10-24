defmodule LiveEmailNotificationWeb.EmailContactsLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.Email

  def render(assigns) do
    ~H"""
      <div>
        <nav class="flex px-6" aria-label="Breadcrumb">
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
                <.link href={~p"/emails"} class="text-xs">
                   emails
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <.link href={~p"/emails/#{@email.id}/contacts"} class={[
                  "text-xs",
                  "border-b border-brand !text-brand"
                ]}>
                  email contacts
                </.link>
              </div>
            </li>
          </ol>
        </nav>
        <header>
            <div class="mx-auto px-4 py-6 sm:px-6 space-y-1 lg:px-8">
              <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
                  Email & Recipients
              </h1>
              <p class="mt-2 text-lg text-slate-700 dark:text-slate-400"><%=@email.subject%></p>
              <p class="text-sm text-slate-500 line-clamp-3 hover:text-slate-600">Content: <%=@email.content%></p>
            </div>
        </header>
        <div class="mx-auto px-4 sm:px-6 space-y-1 lg:px-8">
           <.table id="email-contacts" rows={@email.contacts} callback={JS.push("showAddContact", value: %{"context" => "add"})}>
              <:col :let={contact} label="Contact name"><%= contact.contact_name %></:col>
              <:col :let={contact} label="Contact email"><%= contact.contact_email %></:col>
              <:col :let={contact} label="Send date"><%= contact.inserted_at%></:col>
              <:col :let={contact} label="Status">
                <span class="space-x-2">
                  <span class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">Failed</span>
                  <span class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">Sending</span>
                  <span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">Send</span>
                </span>
              </:col>
              <:col :let={contact} label="Actions">
                <span class="space-x-1.5">
                  <button phx-click="showAddContact" phx-value-selected={contact.id} phx-value-context="delete" type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                    <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Remove contact</span>
                    <dl>
                      <dt class="sr-only">Delete email</dt>
                      <dd>
                        <Heroicons.Outline.minus class="text-red-500 h-3.5 w-3.5" />
                      </dd>
                    </dl>
                  </button>
                  <button phx-click="showAddContact" phx-value-selected={contact.id} phx-value-context="send" type="button" class="border bg-green-50 p-0.5 cursor-pointer has-tooltip">
                    <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Resend</span>
                    <dl>
                      <dt class="sr-only">Resend email</dt>
                      <dd>
                        <Heroicons.Outline.upload class="text-green-500 h-3.5 w-3.5" />
                      </dd>
                    </dl>
                  </button>
                </span>
              </:col>
           </.table>
        </div>
      </div>
    """
  end


  def mount(%{"email_id" => email_id}, session, socket) do
    # fetch email in question
    # add email to assigns
    # preload contacts for the said email along with their statuses
    email = Repo.get_by!(Email, id: String.to_integer(email_id)) |> Repo.preload([:contacts])
    socket = socket |> assign(email: email)
    {:ok, socket}
  end

  def handle_event("showAddContact", %{ "context" => context }, socket) do
    IO.inspect(socket)
  end
end