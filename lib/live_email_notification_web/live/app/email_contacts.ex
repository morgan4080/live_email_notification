defmodule LiveEmailNotificationWeb.EmailContactsLive do
  use LiveEmailNotificationWeb, :live_view

  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Email, ContactEmail, Contact}
  alias LiveEmailNotification.Contexts.{ContactsEmails, Emails, Accounts}
  alias LiveEmailNotification.Helpers.Converter

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
                <.link href={"/admin/users/#{@uuid}/emails"} class="text-xs">
                   emails: <%=@user.email%>
                </.link>
              </div>
            </li>
            <li>
              <div class="flex justify-center">
                <Heroicons.Solid.chevron_right class="text-gray-500 h-4 w-4 shrink-0" />
                <span class="border-b border-brand !text-brand text-xs">
                  email: <%=@email.id%>
                </span>
              </div>
            </li>
          </ol>
        </nav>
        <nav :if={@live_action == :index} class="flex px-4 sm:px-6 lg:px-8" aria-label="Breadcrumb">
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
              <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
                  Email & Contacts
                  <button phx-click={JS.push("showReaction", value: %{"context" => "resend", "ce" => nil, "selected" => nil})} type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
                    <span class="flex items-center text-xs">
                        Send email
                      <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span>
                    </span>
                  </button>
              </h1>
              <p class="mt-2 text-lg text-slate-700 dark:text-slate-400"><%=@email.subject%></p>
              <p class="text-sm text-slate-500 line-clamp-3 hover:text-slate-600">Content: <%=@email.content%></p>
            </div>
        </header>
        <div class="mx-auto px-4 sm:px-6 space-y-1 lg:px-8">
           <.table id="email-contacts" rows={@email.contacts} callback={JS.push("showReaction", value: %{"context" => "resend", "ce" => nil, "selected" => nil})}>
              <:col :let={contact} label="Contact name"><%= contact.contact_name %></:col>
              <:col :let={contact} label="Contact email"><%= contact.contact_email %></:col>
              <:col :let={contact} label="Status">
                <span :for={contact_email <- contact.contacts_emails} class="space-x-2">
                  <span :if={!contact_email.is_email_sent} class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">Failed</span>
                  <span :if={contact_email.is_email_sent} class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">Sent</span>
                </span>
              </:col>
              <:col :let={contact} label="Actions">
                <span class="space-x-1.5">
                  <button phx-click="showReaction" phx-value-selected={contact.id} phx-value-context="remove" phx-value-ce={List.last(contact.contacts_emails).id} type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                    <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Remove</span>
                    <dl>
                      <dt class="sr-only">Delete email</dt>
                      <dd>
                        <Heroicons.Outline.minus class="text-red-500 h-3.5 w-3.5" />
                      </dd>
                    </dl>
                  </button>
                  <button phx-click="showReaction" phx-value-selected={contact.id} phx-value-context="resend" phx-value-ce={List.last(contact.contacts_emails).id} type="button" class="border bg-green-50 p-0.5 cursor-pointer has-tooltip">
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
          <.dialogue
            :if={@modal_active}
            id="email-contacts-dialogue"
            show
            class={[@modal_context == "delete" && "!p-1"]}
          >
            <.live_component
              :if={@modal_context == "resend"}
              module={LiveEmailNotificationWeb.SendEmail}
              id="add_contact_email"
              title="Resend email to contact"
              email={@email}
              form={@form}
              current_user={@user}
              bulk={@bulk}
              trigger_submit={@trigger_submit}
              email_contacts={@email_contacts}
              selected_email={@email}
              selected_email_group_contacts={@selected_email_group_contacts}
              check_errors={@check_errors}
              callbackstatus={JS.navigate(~p"/emails/#{@email.id}/contacts")}
            />
          </.dialogue>
        </div>
      </div>
    """
  end

  # TODO UUID

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "email")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def mount(params, _session, socket) do
    %{"email_id" => email_id} = params
    email = Emails.get_email_by_id(email_id)
    email = email |> Repo.preload([contacts: [contacts_emails: from(ce in ContactEmail, where: ce.email_id == ^email.id)]])
    socket = socket
       |> assign(
          email: email,
          modal_active: false,
          modal_context: false,
          bulk: false,
          trigger_submit: false,
          check_errors: nil,
          selected_user: nil,
          email_contacts: email.contacts |> Enum.map(&(&1.id)),
          selected_email_group_contacts: [],
          user: if (socket.assigns.live_action == :admin) do socket.assigns.selected_user else socket.assigns.current_user end
        ) |> assign_form(Email.email_changeset(email, %{}))

    if socket.assigns.live_action == :admin do
      socket =
        socket
        |> assign(
             uuid: if Map.has_key?(params, "uuid") do params["uuid"] else nil end,
             selected_user: if Map.has_key?(params, "uuid") do Accounts.get_user_by_uid(params["uuid"]) |> Repo.preload([:emails]) else nil end
           )
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("showReaction", %{"context" => context, "ce" => contacts_emails_id, "selected" => contact_id }, socket) do
    case context do
      "resend" ->
        email_contacts = if !is_nil(contact_id) do
          Enum.filter(socket.assigns.email_contacts, fn(c) -> c == Converter.convert!(contact_id) end)
        else
          []
        end

        selected_email_group_contacts = if !is_nil(contact_id) do
          [Repo.get_by(Contact, id: contact_id)]
        else
          []
        end

        {
          :noreply,
          socket
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> assign(:modal_context, context)
             |> assign(:email_contacts, email_contacts) # only selected contact_id
             |> assign(:selected_email_group_contacts, selected_email_group_contacts)
        }
      "remove" ->
        case ContactsEmails.remove_contact_email(contacts_emails_id) do
          {1, nil} ->
            socket = socket |> put_flash(:info, "Contact removed from email") |> redirect(to: socket.assigns.current_path)
            {:noreply, socket}
          _ ->
            socket = socket |> put_flash(:error, "Could not remove contact from email")
            {:noreply, socket}
        end
    end
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

end