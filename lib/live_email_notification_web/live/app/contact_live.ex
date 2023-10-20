defmodule LiveEmailNotificationWeb.ContactLive do
  use LiveEmailNotificationWeb, :live_view
  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Contact}

  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
            <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
            <button phx-click="showAddContact" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center text-xs">Add <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
            </button>
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">View and add contacts to your account.</p>
        </div>
        <.table id="contacts" rows={@current_user.contacts} callback={JS.push("showAddContact", value: %{"context" => "add"})}>
          <:col :let={contact} label="Contact Name"><%= contact.contact_name %></:col>
          <:col :let={contact} label="Contact Email"><%= contact.contact_email %></:col>
          <:col :let={contact} label="Actions">
            <span class="space-x-1">
              <button phx-click="showModal" phx-value-selected={contact.id} phx-value-context="group" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Group</span>
                <dl>
                  <dt class="sr-only">Add to group</dt>
                  <dd>
                    <Heroicons.Outline.plus class="text-teal-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={contact.id} phx-value-context="edit" type="button" class="border bg-zinc-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Edit</span>
                <dl>
                  <dt class="sr-only">Edit contact</dt>
                  <dd>
                    <Heroicons.Outline.pencil class="text-zinc-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={contact.id} phx-value-context="delete" type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Delete</span>
                <dl>
                  <dt class="sr-only">Delete contact</dt>
                  <dd>
                    <Heroicons.Outline.trash class="text-red-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>

              <!-- <%= contact.id %> -->
            </span>
          </:col>
        </.table>
        <.dialogue
          :if={@modal_active}
          id="contact-dialogue"
          show on_cancel={JS.navigate(~p"/contacts")}
          class={[@modal_context == "delete" && "!p-1"]}
        >
          <.live_component
            :if={@modal_context == "add"}
            module={LiveEmailNotificationWeb.CreateContact}
            id="create_contact"
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "group"}
            module={LiveEmailNotificationWeb.ContactGroup}
            id="add_group_contact"
            title="Add Contact to Group"
            contact={@selected_contact}
            form={@group_form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            selected_contact={@selected_contact}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "edit"}
            module={LiveEmailNotificationWeb.UpdateContact}
            id="update_contact"
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "delete"}
            module={LiveEmailNotificationWeb.DeleteConfirm}
            id="delete_contact"
            parent_id="contact-dialogue"
            title="Delete Contact"
            message="Are you sure you want to delete contact? This action cannot be undone."
            contact={@selected_contact}
            error={@custom_error}
          />
        </.dialogue>
      </div>
    """
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "contact")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def assign_contact_group_form(socket, %Ecto.Changeset{} = changeset) do
    group_form = to_form(changeset, as: "contact")

    if changeset.valid? do
      assign(socket, group_form: group_form, check_errors: false)
    else
      assign(socket, group_form: group_form)
    end
  end

  def mount(_params, _session, socket) do
    IO.inspect(socket.assigns.current_user.groups, label: "GROUPS")
    socket =
      socket
      |> assign(
           trigger_submit: false,
           check_errors: false,
           modal_active: false,
           modal_context: "add",
           custom_error: nil,
           selected_contact: nil,
           page_title: "Contact"
         )
      |> assign_form(Contact.user_contact_changeset(%Contact{}, %{}))
      |> assign_contact_group_form(Contact.group_contact_changeset(%Contact{}, %{}))
    {:ok, socket}
  end

  def handle_event("showAddContact", %{ "context" => context }, socket) do
    modal_active = !socket.assigns.modal_active
    socket = socket
             |> assign(:modal_active, modal_active)
             |> assign(:modal_context, context)
    {:noreply, socket}
  end

  def handle_event("showModal", %{ "selected" => contact_id, "context" => context }, socket) do
    selected_contact = Repo.get_by(Contact, id: elem(Integer.parse(contact_id), 0))
    %Contact{id: id, contact_name: contact_name, contact_email: contact_email, groups: groups} = selected_contact
    preload_contact_to_form = %Contact{id: id, contact_name: contact_name, contact_email: contact_email, groups: groups}
    socket = socket
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> assign(:modal_context, context)
             |> assign(:selected_contact, selected_contact)
             |> assign_form(Contact.user_contact_changeset(preload_contact_to_form, %{}))
             |> assign_contact_group_form(Contact.group_contact_changeset(preload_contact_to_form, %{}))
    {:noreply, socket}
  end

  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = Contact.user_contact_changeset(
      %Contact{},
      contact_params
    )

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("create", %{"contact" => contact_params}, socket) do
    if user = socket.assigns.current_user do
      %{"contact_name" => contact_name, "contact_email" => contact_email} = contact_params
      case  %Contact{contact_name: contact_name, contact_email: contact_email, user_id: user.id}
            |> Contact.user_contact_changeset(contact_params)
            |> Repo.insert()
        do
          {:ok, contact} ->
            socket = socket
                     |> assign(trigger_submit: true)
                     |> assign_form(Contact.user_contact_changeset(contact, contact_params))
                     |> put_flash(:info, "Contact created successfully.")
                     |> redirect(to: ~p"/contacts")
            {:noreply, socket}
          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply, assign(socket, check_errors: true)}
    end
  end

  def handle_event("update", %{"contact" => contact_params}, socket) do
    %{"id" => id,"contact_name" => contact_name, "contact_email" => contact_email} = contact_params

    IO.inspect(contact_params, label: "contact_params")
#    changeset = %Contact{contact_name: contact_name, contact_email: contact_email} |> Contact.user_contact_changeset(contact_params)
#    case Repo.update(:contact, changeset) do
#      {:ok, contact} ->
#        socket = socket
#                 |> assign(trigger_submit: true)
#                 |> assign_form(Contact.user_contact_changeset(contact, contact_params))
#                 |> put_flash(:info, "Contact updated successfully.")
#                 |> redirect(to: ~p"/contacts")
#        {:noreply, socket}
#      {:error, %Ecto.Changeset{} = changeset} ->
#        {:noreply, assign_form(socket, changeset)}
#    end

    {:noreply, socket}
  end

  def handle_event("delete", %{ "selected" => contact_id}, socket) do
    try do
      cont_id = elem(Integer.parse(contact_id), 0)
      Repo.delete_all from(contact in Contact, where: contact.id == ^cont_id)
      socket = socket
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Contact deleted successfully.")
               |> redirect(to: ~p"/contacts")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end
end
