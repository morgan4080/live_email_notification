defmodule LiveEmailNotificationWeb.EmailLive do
  use LiveEmailNotificationWeb, :live_view

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.Email
  alias LiveEmailNotification.Contexts.Emails

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
                <.link href={"/admin/users/#{@uuid}/dashboard"} class="text-xs">
                   dashboard
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <.link href={"/admin/users/#{@uuid}/emails"} class={[
                  "text-xs",
                  @selected_path == "/emails" && "border-b border-brand !text-brand"
                ]}>
                  <%=String.split(@selected_path, "/")%>: <%=@user.email%>
                </.link>
              </div>
            </li>
          </ol>
        </nav>
        <div class="mx-auto px-4 py-6 sm:px-6 space-y-1 lg:px-8">
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
              Emails
              <button phx-click="showAddEmail" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
                <span class="flex items-center text-xs">Create <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
              </button>
            </h1>
            <p class="text-sm text-slate-500 hover:text-slate-600">View and send emails for account.</p>
          </div>
          <.table id="emails" rows={@user.emails |> Repo.preload([:contacts])} callback={JS.push("showAddEmail", value: %{"context" => "add"})}>
            <:col :let={email} label="Subject"><p class="max-w-xs overflow-hidden text-ellipsis"><%= email.subject %></p></:col>
            <:col :let={email} label="Content"><p class="line-clamp-3 max-w-md"><%= email.content %></p></:col>
            <:col :let={email} label="Contacts Count">
              <.link href={"#{@current_path}/#{email.id}/contacts"} class="text-blue-400">
                <%= length(email.contacts) %>
              </.link>
            </:col>
            <:col :let={email} label="Created"><%= email.inserted_at%></:col>
            <:col :let={email} label="Actions">
              <span class="space-x-1.5">
                <button phx-click="showModal" phx-value-selected={email.id} phx-value-context="send" type="button" class="border bg-green-50 p-0.5 cursor-pointer has-tooltip">
                  <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Send Email</span>
                  <dl>
                    <dt class="sr-only">View email</dt>
                    <dd>
                      <Heroicons.Outline.paper_airplane class="text-green-500 h-3.5 w-3.5 rotate-90" />
                    </dd>
                  </dl>
                </button>
                <button phx-click={JS.navigate("#{@current_path}/#{email.id}/contacts")} type="button" class="border bg-blue-50 p-0.5 cursor-pointer has-tooltip">
                  <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Contacts</span>
                  <dl>
                    <dt class="sr-only">View email contacts</dt>
                    <dd>
                      <Heroicons.Outline.user class="text-blue-500 h-3.5 w-3.5" />
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
            on_cancel={JS.navigate(@current_path)}
            class={[@modal_context == "delete" && "!p-1"]}
          >
            <.live_component
              :if={@modal_context == "add"}
              module={LiveEmailNotificationWeb.CreateEmail}
              id="create_email"
              form={@form}
              current_user={@user}
              trigger_submit={@trigger_submit}
              check_errors={@check_errors}
            />
            <.live_component
              :if={@modal_context == "edit"}
              module={LiveEmailNotificationWeb.UpdateEmail}
              id="update_email"
              form={@form}
              current_user={@user}
              trigger_submit={@trigger_submit}
              check_errors={@check_errors}
            />
            <.live_component
              :if={@modal_context == "delete"}
              module={LiveEmailNotificationWeb.DeleteConfirm}
              id="delete_email"
              parent_id="email-dialogue"
              title="Delete Email"
              message="Are you sure you want to delete email? This action cannot be undone."
              subject={@selected_email.subject}
              subject_id={@selected_email.id}
              error={@custom_error}
            />
            <.live_component
              :if={@modal_context == "send"}
              module={LiveEmailNotificationWeb.SendEmail}
              id="add_contact_email"
              title="Send email to Contacts or Group"
              email={@selected_email}
              form={@form}
              current_user={@user}
              bulk={@bulk}
              trigger_submit={@trigger_submit}
              email_contacts={@email_contacts}
              selected_email={@selected_email}
              selected_email_group_contacts={@selected_email_group_contacts}
              check_errors={@check_errors}
              callbackstatus={JS.navigate(~p"/emails/#{@selected_email.id}/contacts")}
            />
          </.dialogue>
        </div>
      </div>
    """
  end


  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "email")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(
           trigger_submit: false,
           check_errors: false,
           bulk: false,
           modal_active: Map.has_key?(params, "action"),
           modal_context: Map.get(params, "action"),
           custom_error: nil,
           selected_email: nil,
           selected_path: "/emails",
           user: if (socket.assigns.live_action == :admin) do socket.assigns.selected_user else socket.assigns.current_user end,
           selected_email_group_contacts: [],
           page_title: "Emails"
         )
      |> assign_form(Email.email_changeset(%Email{}, %{}))

    {:ok, socket}
  end

  def handle_event("showAddEmail", %{ "context" => context }, socket) do
    modal_active = !socket.assigns.modal_active
    socket = socket
             |> assign(:modal_active, modal_active)
             |> assign(:modal_context, context)
    {:noreply, socket}
  end

  def handle_event("showModal", %{ "selected" => email_id, "context" => context }, socket) do
    selected_email = Repo.get_by(Email, id: elem(Integer.parse(email_id), 0))
                       |> Repo.preload([:contacts])
    socket = socket
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> assign(:modal_context, context)
             |> assign(:email_contacts, selected_email.contacts |> Enum.map(&(&1.id)))
             |> assign(:selected_email, selected_email)
             |> assign_form(Email.email_changeset(selected_email, %{}))
    {:noreply, socket}
  end

  def handle_event("validate", %{"email" => email_params}, socket) do
    case Emails.validate_email(email_params) do
      {:ok,  %{
        "changeset" => changeset,
        "bulk" => bulk,
        "selected_email_group_contacts" => selected_email_group_contacts
      }} ->
        {:noreply,
          socket
          |> assign_form(Map.put(changeset, :action, :validate))
          |> assign(
             bulk: bulk,
             selected_email_group_contacts: selected_email_group_contacts
           )
        }
    end
  end

  def handle_event("update", %{"email" => email_params}, socket) do
    case Emails.update_email(email_params) do
      {:ok, message} ->
        {:noreply, socket
                   |> assign(trigger_submit: true)
                   |> assign(:modal_active, !socket.assigns.modal_active)
                   |> put_flash(:info, message)
                   |> redirect(to: socket.assigns.current_path)}
      {:error, message} ->
        {:noreply, socket |> assign(:custom_error, message) |> put_flash(:error, message)}
    end
  end

  def handle_event("create", %{"email" => email_params}, socket) do
    case Emails.create_email(email_params, socket.assigns.user) do
      {:ok, email} ->
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(Email.email_changeset(email, email_params)) |> put_flash(:info, "Email created successfully.") |> redirect(to: socket.assigns.current_path)}
      {:error, message} ->
        {:noreply, socket |> assign_form(%Ecto.Changeset{}) |> put_flash(:error, message) |> assign(check_errors: true)}
    end
  end

  def handle_event("send-email", %{"email" => email_params}, socket) do
    case Emails.associate_email_to_contacts_and_groups(
       email_params,
       socket.assigns.selected_email_group_contacts,
       socket.assigns.live_action,
       socket.assigns.user.id
      )
    do
      {:ok, %{"email" => email, "email_changes" => email_changes, "message" => message}} ->
        case Emails.upsert_email_contacts_groups_que_mails(email, email_changes) do
          {:ok, _email_id} ->
            socket = socket
                     |> assign(trigger_submit: true)
                     |> assign_form(Email.email_changeset(%Email{}, email_params))
                     |> put_flash(:info, message)
                     |> redirect(to: socket.assigns.current_path)
            {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
          {:error, message} ->
            socket = socket
                     |> put_flash(:error, message)
                     |> assign_form(%Ecto.Changeset{})
                     |> assign(check_errors: true)
            {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
        end
    end
  end

  def handle_event("delete", %{ "selected" => email_id}, socket) do
    case Emails.delete_email(email_id) do
      {:ok, message} ->
        {:noreply, socket |> assign(:modal_active, !socket.assigns.modal_active) |> put_flash(:info, message) |> redirect(to: socket.assigns.current_path)}
      {:error, message} ->
        {:noreply, socket |> assign(:custom_error, message) |> put_flash(:error, message)}
    end
  end
end
