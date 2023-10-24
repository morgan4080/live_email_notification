defmodule LiveEmailNotificationWeb.EmailLive do
  use LiveEmailNotificationWeb, :live_view

  import Ecto.Query

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Contact, Email, Group}

  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
            <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
            <button phx-click="showAddEmail" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center text-xs">Create <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
            </button>
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">View and send emails.</p>
        </div>
        <.table id="emails" rows={@current_user.emails} callback={JS.push("showAddEmail", value: %{"context" => "add"})}>
          <:col :let={email} label="Subject"><%= email.subject %></:col>
          <:col :let={email} label="Content"><%= email.content %></:col>
          <:col :let={email} label="Created"><%= email.inserted_at%></:col>
          <:col :let={email} label="Actions">
            <span class="space-x-1">
              <button phx-click="showModal" phx-value-selected={email.id} phx-value-context="send" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Email</span>
                <dl>
                  <dt class="sr-only">View email</dt>
                  <dd>
                    <Heroicons.Outline.mail class="text-teal-500 h-3.5 w-3.5" />
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
          <.live_component
            :if={@modal_context == "add"}
            module={LiveEmailNotificationWeb.CreateEmail}
            id="create_email"
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "edit"}
            module={LiveEmailNotificationWeb.UpdateEmail}
            id="update_email"
            form={@form}
            current_user={@current_user}
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
            current_user={@current_user}
            bulk={@bulk}
            trigger_submit={@trigger_submit}
            email_contacts={@email_contacts}
            selected_email={@selected_email}
            selected_email_group_contacts={@selected_email_group_contacts}
            check_errors={@check_errors}
            callback={JS.navigate(~p"/contacts?action=add")}
          />
        </.dialogue>
      </div>
    """
  end

  defmodule Converter do
    def convert!("true"), do: true
    def convert!("false"), do: false
    def convert!(num), do: String.to_integer(num)
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
    IO.inspect(email_params, label: "ISBULK")
    if contact_ids = email_params["contacts"] do
      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)
      contacts = Repo.all(from c in Contact,
                        where: c.id in ^selected_contacts_ints,
                        select: c) |> Repo.preload([:groups, :emails])

      contacts_map = Enum.map(contacts, fn contact ->
        Map.from_struct(%{contact | groups: []})
      end)

      email_params = %{email_params | "contacts" => contacts_map}

      changeset = Email.email_changeset(
        %Email{},
        email_params
      )

      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate)) |> assign(bulk:  Enum.map([email_params["is_bulk"]], &Converter.convert!/1) |> List.last())}
    else
      if group_ids = email_params["groups"] do
        selected_groups_ints = Enum.map(group_ids, fn group -> elem(Integer.parse(group), 0) end)
        groups = Repo.all(from g in Group,
                           where: g.id in ^selected_groups_ints,
                           select: g) |> Repo.preload([:contacts])
        contacts_lists = Enum.flat_map(groups, fn group ->
          Enum.map(group.contacts, fn contact ->
            Map.from_struct(contact)
          end)
        end)

        changeset = Email.email_changeset(
          %Email{},
          email_params
        )

        {:noreply,
          assign_form(socket, Map.put(changeset, :action, :validate))
          |> assign(
            bulk: Enum.map([email_params["is_bulk"]], &Converter.convert!/1) |> List.last(),
            selected_email_group_contacts: Enum.uniq(contacts_lists)
          )
        }
      else
        changeset = Email.email_changeset(
          %Email{},
          email_params
        )

        {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
      end
    end
  end

  def handle_event("update", %{"email" => email_params}, socket) do
    try do
      %{"id" => id, "subject" => subject, "content" => content} = email_params
      e_id = elem(Integer.parse(id), 0)
      from(email in Email, where: email.id == ^e_id, update: [set: [subject: ^subject, content: ^content]])
      |> Repo.update_all([])
      socket = socket
               |> assign(trigger_submit: true)
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Email updated successfully.")
               |> redirect(to: ~p"/emails")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end

  def handle_event("create", %{"email" => email_params}, socket) do
    if user = socket.assigns.current_user do
      %{"subject" => subject, "content" => content} = email_params

      email = %Email{subject: subject, content: content, user_id: user.id, contacts: []}

      email_changeset = Email.email_changeset(email, email_params)

      if email_changeset.valid? do
        try do
          email = Repo.insert!(email_changeset)
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Email.email_changeset(email, email_params))
                   |> put_flash(:info, "Email created successfully.")
                   |> redirect(to: ~p"/emails")
          {:noreply, socket}
        catch
          _message ->
            socket = socket
                     |> assign_form(%Ecto.Changeset{})
                     |> assign(check_errors: true)
            {:noreply, socket}
        end
      else
        socket = socket
                 |> assign_form(%Ecto.Changeset{})
                 |> assign(check_errors: true)
        {:noreply, socket}
      end
    else
      {:noreply, assign(socket, check_errors: true)}
    end
  end

  def handle_event("send-email", %{"email" => email_params}, socket) do
    # update email
    # associate email to contacts
    # start emails job
    %{"content" => content, "id" => email_id, "subject" => subject} = email_params
    if contact_ids = email_params["contacts"] do
      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)
      contacts = Repo.all(from c in Contact,
                          where: c.id in ^selected_contacts_ints,
                          select: c) |> Repo.preload([:groups, :emails])
      contacts_map = Enum.map(contacts, fn contact ->
        Map.from_struct(%{contact | groups: []})
      end)

      email_params = %{email_params | "contacts" => contacts_map}

      IO.inspect(email_params, label: "EMAIL PARAMS")
    else
      if group_ids = email_params["groups"] do
        email_params = %{email_params | "contacts" => socket.assigns.selected_email_group_contacts}
        IO.inspect(email_params, label: "EMAIL PARAMS")
      else
        {:noreply, socket}
      end
    end
    {:noreply, socket}
  end

  def handle_event("delete", %{ "selected" => email_id}, socket) do
    try do
      em_id = elem(Integer.parse(email_id), 0)
      Repo.delete_all from(email in Email, where: email.id == ^em_id)
      socket = socket
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Email deleted successfully.")
               |> redirect(to: ~p"/emails")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end
end
