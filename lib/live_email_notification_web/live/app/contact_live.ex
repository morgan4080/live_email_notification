defmodule LiveEmailNotificationWeb.ContactLive do
  use LiveEmailNotificationWeb, :live_view
  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Contact, Group}

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
                <.link href={"/admin/users/#{@uuid}/contacts"} class={[
                  "text-xs",
                  @selected_path == "/contacts" && "border-b border-brand !text-brand"
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
              Contacts
              <button phx-click="showAddContact" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
                <span class="flex items-center text-xs">Add <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
              </button>
            </h1>
            <p class="text-sm text-slate-500 hover:text-slate-600">View and add contacts to the account.</p>
          </div>
          <.table id="contacts" rows={@user.contacts |> Repo.preload([:emails, :groups])} callback={JS.push("showAddContact", value: %{"context" => "add"})}>
            <:col :let={contact} label="Contact Name"><%= contact.contact_name %></:col>
            <:col :let={contact} label="Contact Email"><%= contact.contact_email %></:col>
            <:col :let={contact} label="Email Count"><%= length(contact.emails) %></:col>
            <:col :let={contact} label="Group Count"><%= length(contact.groups) %></:col>
            <:col :let={contact} label="Actions">
              <span class="space-x-1">
                <button :if={@user.plan.plan_name == "Gold"} phx-click="showModal" phx-value-selected={contact.id} phx-value-context="group" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
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
              </span>
            </:col>
          </.table>
          <.dialogue
            :if={@modal_active}
            id="contact-dialogue"
            show
            on_cancel={JS.navigate(@current_path)}
            class={[@modal_context == "delete" && "!p-1"]}
          >
            <.live_component
              :if={@modal_context == "add"}
              module={LiveEmailNotificationWeb.CreateContact}
              id="create_contact"
              form={@form}
              current_user={@user}
              trigger_submit={@trigger_submit}
              check_errors={@check_errors}
            />
            <.live_component
              :if={@modal_context == "group"}
              module={LiveEmailNotificationWeb.ContactGroup}
              id="add_group_contact"
              title="Add Contact to Groups"
              contact={@selected_contact}
              form={@form}
              current_user={@user}
              trigger_submit={@trigger_submit}
              contact_groups={@contact_groups}
              selected_contact={@selected_contact}
              check_errors={@check_errors}
              callback={JS.navigate(~p"/groups?action=add")}
            />
            <.live_component
              :if={@modal_context == "edit"}
              module={LiveEmailNotificationWeb.UpdateContact}
              id="update_contact"
              form={@form}
              current_user={@user}
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
              subject={@selected_contact.contact_email}
              subject_id={@selected_contact.id}
              error={@custom_error}
            />
          </.dialogue>
        </div>
      </div>
    """
  end

  def upsert_contact_groups(contact, group_ids) when is_list(group_ids) do
    groups = Group |> where([g], g.id in ^group_ids) |> Repo.all()

    with {:ok, _struct} <-
           contact
           |> Contact.changeset_update_groups(groups)
           |> Repo.update() do
      {:ok, Repo.get_by(Contact, id: contact.id)}
    else
      error ->
        {:error, error}
    end
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "contact")

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
           modal_active: Map.has_key?(params, "action"),
           modal_context: Map.get(params, "action"),
           custom_error: nil,
           selected_contact: nil,
           selected_path: "/contacts",
           contact_groups: [],
           user: if (socket.assigns.live_action == :admin) do socket.assigns.selected_user else socket.assigns.current_user end,
           page_title: "Contact"
         )
      |> assign_form(Contact.user_contact_changeset(%Contact{}, %{}))
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
                       |> Repo.preload([:groups, :emails])
    socket = socket
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> assign(:modal_context, context)
             |> assign(:contact_groups, selected_contact.groups |> Enum.map(&(&1.id)))
             |> assign(:selected_contact, selected_contact)
             |> assign_form(Contact.user_contact_changeset(selected_contact, %{}))
    {:noreply, socket}
  end

  def handle_event("validate", %{"contact" => contact_params}, socket) do
    if group_ids = contact_params["groups"] do
      selected_groups_ints = Enum.map(group_ids, fn group -> elem(Integer.parse(group), 0) end)
      groups = Repo.all(from g in Group,
                    where: g.id in ^selected_groups_ints,
                    select: g) |> Repo.preload([:contacts, :emails])

      groups_map = Enum.map(groups, fn group ->
        Map.from_struct(%{group | contacts: [], emails: []})
      end)

      contact_params = %{contact_params | "groups" => groups_map}

      changeset = Contact.user_contact_changeset(
        %Contact{},
        contact_params
      )

      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    else
      changeset = Contact.user_contact_changeset(
        %Contact{},
        contact_params
      )

      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def handle_event("create", %{"contact" => contact_params}, socket) do
    if user = socket.assigns.user do
      %{"contact_name" => contact_name, "contact_email" => contact_email} = contact_params

      contact = %Contact{contact_name: contact_name, contact_email: contact_email, user_id: user.id, groups: [], emails: []}

      contact_changeset = Contact.user_contact_changeset(contact, contact_params)

      if contact_changeset.valid? do
        try do
          contact = Repo.insert!(contact_changeset)
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Contact.user_contact_changeset(contact, contact_params))
                   |> put_flash(:info, "Contact created successfully.")
                   |> redirect(to: ~p"/contacts")
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

  def handle_event("update", %{"contact" => contact_params}, socket) do
    try do
      %{"id" => id,"contact_name" => contact_name, "contact_email" => contact_email} = contact_params
      cont_id = elem(Integer.parse(id), 0)
      from(contact in Contact, where: contact.id == ^cont_id, update: [set: [contact_name: ^contact_name, contact_email: ^contact_email]])
      |> Repo.update_all([])
      socket = socket
               |> assign(trigger_submit: true)
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Contact updated successfully.")
               |> redirect(to: ~p"/contacts")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end

  def handle_event("update-groups", %{"contact" => contact_params}, socket) do
    if contact_params["groups"] do
      %{"id" => id, "groups" => group_ids } = contact_params
      selected_groups_ints = Enum.map(group_ids, fn group -> elem(Integer.parse(group), 0) end)

      contact = Repo.get_by(Contact, id: elem(Integer.parse(id), 0)) |> Repo.preload([:groups, :emails])

      case upsert_contact_groups(contact, selected_groups_ints) do
        {:ok, _contact_id} ->
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Contact.user_contact_changeset(%Contact{}, contact_params))
                   |> put_flash(:info, "Groups associated successfully.")
                   |> redirect(to: ~p"/contacts")
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
        {:error, _message} ->
          socket = socket
                   |> assign_form(%Ecto.Changeset{})
                   |> assign(check_errors: true)
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
      end
    else
      %{"id" => id } = contact_params

      contact = Repo.get_by(Contact, id: elem(Integer.parse(id), 0)) |> Repo.preload([:groups, :emails])

      case upsert_contact_groups(contact, []) do
        {:ok, _contact_id} ->
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Contact.user_contact_changeset(%Contact{}, contact_params))
                   |> put_flash(:info, "Groups disassociated successfully.")
                   |> redirect(to: ~p"/contacts")
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
        {:error, _message} ->
          socket = socket
                   |> assign_form(%Ecto.Changeset{})
                   |> assign(check_errors: true)
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
      end
    end
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
