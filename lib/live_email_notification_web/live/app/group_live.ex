defmodule LiveEmailNotificationWeb.GroupLive do
  use LiveEmailNotificationWeb, :live_view
  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Group, Contact}

  def render(assigns) do
    ~H"""
      <div class="mx-auto px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
            <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
            <button phx-click="showAddGroup" phx-value-context="add" type="button" class="absolute right-0 inline-flex justify-center rounded-full text-sm font-semibold p-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center text-xs">Add <span class="ml-1" aria-hidden="true"><Heroicons.Solid.plus class="h-2.5 w-2.5" /></span></span>
            </button>
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">View and add groups to your account.</p>
        </div>
        <.table id="groups" rows={@current_user.groups} callback={JS.push("showAddGroup", value: %{"context" => "add"})}>
          <:col :let={group} label="Group Name"><%= group.group_name %></:col>
          <:col :let={group} label="Group Description"><%= group.group_description %></:col>
          <:col :let={group} label="Actions">
            <span class="space-x-1">
              <button phx-click="showModal" phx-value-selected={group.id} phx-value-context="group" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Contacts</span>
                <dl>
                  <dt class="sr-only">Add contacts to group</dt>
                  <dd>
                    <Heroicons.Outline.plus class="text-teal-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={group.id} phx-value-context="edit" type="button" class="border bg-zinc-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Edit</span>
                <dl>
                  <dt class="sr-only">Edit group</dt>
                  <dd>
                    <Heroicons.Outline.pencil class="text-zinc-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button phx-click="showModal" phx-value-selected={group.id} phx-value-context="delete" type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Delete</span>
                <dl>
                  <dt class="sr-only">Delete group</dt>
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
          id="group-dialogue"
          show
          on_cancel={JS.navigate(~p"/groups")}
          class={[@modal_context == "delete" && "!p-1"]}
        >
          <.live_component
            :if={@modal_context == "add"}
            module={LiveEmailNotificationWeb.CreateGroup}
            id="create_group"
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "group"}
            module={LiveEmailNotificationWeb.GroupContact}
            id="add_contact_group"
            title="Add Group to Contacts"
            contact={@selected_group}
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            group_contacts={@group_contacts}
            selected_group={@selected_group}
            check_errors={@check_errors}
            callback={JS.navigate(~p"/contacts?action=add")}
          />
          <.live_component
            :if={@modal_context == "edit"}
            module={LiveEmailNotificationWeb.UpdateGroup}
            id="update_group"
            form={@form}
            current_user={@current_user}
            trigger_submit={@trigger_submit}
            check_errors={@check_errors}
          />
          <.live_component
            :if={@modal_context == "delete"}
            module={LiveEmailNotificationWeb.DeleteConfirm}
            id="delete_group"
            parent_id="group-dialogue"
            title="Delete Group"
            message="Are you sure you want to delete group? This action cannot be undone."
            subject={@selected_group.group_name}
            subject_id={@selected_group.id}
            error={@custom_error}
          />
        </.dialogue>
      </div>
    """
  end

  def upsert_group_contacts(group, contact_ids) when is_list(contact_ids) do
    contacts = Contact |> where([c], c.id in ^contact_ids) |> Repo.all()

    with {:ok, _struct} <-
           group
           |> Group.changeset_update_contacts(contacts)
           |> Repo.update() do
      {:ok, Repo.get_by(Group, id: group.id)}
    else
      error ->
        error
    end
  end


  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "group")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def assign_group_contact_form(socket, %Ecto.Changeset{} = changeset) do
    contact_form = to_form(changeset, as: "group")

    if changeset.valid? do
      assign(socket, contact_form: contact_form, check_errors: false)
    else
      assign(socket, contact_form: contact_form)
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
           selected_group: nil,
           group_contacts: [],
           page_title: "Groups"
         )
      |> assign_form(Group.group_changeset(%Group{}, %{}))
    {:ok, socket}
  end

  def handle_event("showAddGroup", %{ "context" => context }, socket) do
    modal_active = !socket.assigns.modal_active
    socket = socket
             |> assign(:modal_active, modal_active)
             |> assign(:modal_context, context)
    {:noreply, socket}
  end

  def handle_event("showModal", %{ "selected" => group_id, "context" => context }, socket) do
    selected_group = Repo.get_by(Group, id: elem(Integer.parse(group_id), 0))
                     |> Repo.preload([:contacts])
    %Group{id: id, group_name: group_name, group_description: group_description, contacts: contacts} = selected_group
    preload_group_to_form = %Group{id: id, group_name: group_name, group_description: group_description, contacts: contacts}
    socket = socket
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> assign(:modal_context, context)
             |> assign(:group_contacts, selected_group.contacts |> Enum.map(&(&1.id)))
             |> assign(:selected_group, selected_group)
             |> assign_form(Group.group_changeset(preload_group_to_form, %{}))
    {:noreply, socket}
  end

  def handle_event("validate", %{"group" => group_params}, socket) do
    if contact_ids = group_params["contacts"] do
      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)
      contacts = Repo.all(from c in Contact,
                        where: c.id in ^selected_contacts_ints,
                        select: c) |> Repo.preload([:groups, :emails])

      contacts_map = Enum.map(contacts, fn contact ->
        Map.from_struct(%{contact | groups: []})
      end)

      group_params = %{group_params | "contacts" => contacts_map}

      changeset = Group.group_changeset(
        %Group{},
        group_params
      )

      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    else
      changeset = Group.group_changeset(
        %Group{},
        group_params
      )

      {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
    end
  end

  def handle_event("create", %{"group" => group_params}, socket) do
    if user = socket.assigns.current_user do
      %{"group_name" => group_name, "group_description" => group_description} = group_params
      case  %Group{group_name: group_name, group_description: group_description, user_id: user.id}
            |> Group.group_changeset(group_params)
            |> Repo.insert()
        do
        {:ok, group} ->
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Group.group_changeset(group, group_params))
                   |> put_flash(:info, "Group created successfully.")
                   |> redirect(to: ~p"/groups")
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    else
      {:noreply, assign(socket, check_errors: true)}
    end
  end

  def handle_event("update", %{"group" => group_params}, socket) do
    try do
      %{"id" => id,"group_name" => group_name, "group_description" => group_description} = group_params
      g_id = elem(Integer.parse(id), 0)
      from(group in Group, where: group.id == ^g_id, update: [set: [group_name: ^group_name, group_description: ^group_description]])
      |> Repo.update_all([])
      socket = socket
               |> assign(trigger_submit: true)
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Group updated successfully.")
               |> redirect(to: ~p"/groups")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end

  def handle_event("update-contacts", %{"group" => group_params}, socket) do
    if group_params["contacts"] do
      %{"id" => id, "contacts" => contact_ids } = group_params
      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)

      group = Repo.get_by(Group, id: elem(Integer.parse(id), 0)) |> Repo.preload([:contacts])

      case upsert_group_contacts(group, selected_contacts_ints) do
        {:ok, _group_id} ->
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Group.group_changeset(%Group{}, group_params))
                   |> put_flash(:info, "Contacts associated successfully.")
                   |> redirect(to: ~p"/groups")
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
        {:error, _message} ->
          socket = socket
                   |> assign_form(%Ecto.Changeset{})
                   |> assign(check_errors: true)
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
      end
    else
      %{"id" => id } = group_params

      group = Repo.get_by(Group, id: elem(Integer.parse(id), 0)) |> Repo.preload([:contacts])

      case upsert_group_contacts(group, []) do
        {:ok, _group_id} ->
          socket = socket
                   |> assign(trigger_submit: true)
                   |> assign_form(Group.group_changeset(%Group{}, group_params))
                   |> put_flash(:info, "Contacts disassociated successfully.")
                   |> redirect(to: ~p"/groups")
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
        {:error, _message} ->
          socket = socket
                   |> assign_form(%Ecto.Changeset{})
                   |> assign(check_errors: true)
          {:noreply, assign_form(socket, Map.put(%Ecto.Changeset{}, :action, :update))}
      end
    end
  end

  def handle_event("delete", %{ "selected" => group_id}, socket) do
    try do
      gro_id = elem(Integer.parse(group_id), 0)
      Repo.delete_all from(group in Group, where: group.id == ^gro_id)
      socket = socket
               |> assign(:modal_active, !socket.assigns.modal_active)
               |> put_flash(:info, "Group deleted successfully.")
               |> redirect(to: ~p"/groups")
      {:noreply, socket}
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end
end
