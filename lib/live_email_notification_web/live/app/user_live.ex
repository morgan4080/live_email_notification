defmodule LiveEmailNotificationWeb.UserLive do
  use LiveEmailNotificationWeb, :live_view

  import Ecto.Query

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{User, Plan, UserType}


  def render(assigns) do
    ~H"""
      <div class="mx-auto px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise relative">
            Users
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">View users and do <span class="border-b border-brand"><%= @current_user.user_type.user_type %></span> stuff.</p>
        </div>
        <.table id="users" rows={@users}>
          <:col :let={user} label="Full Name"><%= user.first_name %> <%= user.last_name %></:col>
          <:col :let={user} label="Email"><%= user.email %></:col>
          <:col :let={user} label="Phone no."><%= user.msisdn %></:col>
          <:col :let={user} label="Plan"><%= user.plan.plan_name %></:col>
          <:col :let={user} label="Permission"><%= user.user_type.user_type %></:col>
          <:col :let={user} label="Actions">
            <div class="space-x-1">
              <button :if={@current_user.uuid != user.uuid && user.user_type.user_type != "superuser"} phx-click="view" phx-value-selected={user.uuid} phx-value-context="view" type="button" class="border bg-blue-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">View account</span>
                <dl>
                  <dt class="sr-only">View User</dt>
                  <dd>
                    <Heroicons.Outline.eye class="text-blue-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button :if={@current_user.user_type.user_type == "superuser"} phx-click="showModal" phx-value-selected={user.id} phx-value-context="plan" type="button" class="border bg-teal-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Change plan</span>
                <dl>
                  <dt class="sr-only">Upgrade Plan</dt>
                  <dd>
                    <Heroicons.Solid.chevron_double_up class="text-teal-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button :if={@current_user.user_type.user_type == "superuser"} phx-click="showModal" phx-value-selected={user.id} phx-value-context="permission" type="button" class="border bg-slate-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Change permissions</span>
                <dl>
                  <dt class="sr-only">Change permissions</dt>
                  <dd>
                    <Heroicons.Solid.key class="text-slate-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
              <button :if={@current_user.uuid != user.uuid && user.user_type.user_type != "superuser"} phx-click="showModal" phx-value-selected={user.id} phx-value-context="delete" type="button" class="border bg-red-50 p-0.5 cursor-pointer has-tooltip">
                <span class="tooltip rounded shadow-lg p-1 bg-black text-white -mt-8 text-xs">Delete</span>
                <dl>
                  <dt class="sr-only">Delete user</dt>
                  <dd>
                    <Heroicons.Outline.trash class="text-red-500 h-3.5 w-3.5" />
                  </dd>
                </dl>
              </button>
            </div>
          </:col>
        </.table>
        <.dialogue
          :if={@modal_active}
          id="user-dialogue"
          show
          on_cancel={JS.navigate(~p"/admin/users")}
          class="!p-1"
        >
          <.live_component
            :if={@modal_context == "delete"}
            module={LiveEmailNotificationWeb.DeleteConfirm}
            id="delete_user"
            parent_id="user-dialogue"
            title="Delete User"
            message="Are you sure you want to delete user and all associated records? This action cannot be undone."
            subject={@selected_user.email}
            subject_id={@selected_user.id}
            error={@custom_error}
          />
          <.live_component
            :if={@modal_context == "plan"}
            id="change_user_plan"
            module={LiveEmailNotificationWeb.ChangePlan}
            trigger_submit={@trigger_submit}
            parent_id="user-dialogue"
            subject={@selected_user.email}
            subject_id={@selected_user.id}
            plans={@plans}
            form={@form}
            message={"You are about to change the user plan for: " <> @selected_user.first_name <> " " <> @selected_user.last_name <> ". Select the plan you wish to change to below."}
          />
          <.live_component
            :if={@modal_context == "permission"}
            id="change_user_permission"
            module={LiveEmailNotificationWeb.ChangePermission}
            trigger_submit={@trigger_submit}
            parent_id="user-dialogue"
            subject={@selected_user.email}
            subject_id={@selected_user.id}
            user_types={@user_types}
            form={@form}
            message={"You are about to change permissions for user: " <> @selected_user.email <> ". Select the permission you wish to change to below."}
          />
        </.dialogue>
      </div>
    """
  end

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def mount(params, _session, socket) do
    socket = case socket.assigns.current_user.user_type.user_type do
      "superuser" ->
        socket =
          socket
          |> assign(
               users: Repo.all(from u in User, order_by: u.inserted_at) |> Repo.preload([:user_type, :plan])
             )

        socket
      "admin" ->
        socket =
          socket
          |> assign(
               users: Repo.all(from u in User, order_by: u.inserted_at) |> Repo.preload([:user_type, :plan]) # if users belonging to certain admin
             )

        socket
      _ ->
        socket =
          socket
          |> assign(
               users: []
             )

        socket
    end

    socket = socket |> assign(
      page_title: "Users",
      trigger_submit: false,
      selected_user: nil,
      check_errors: false,
      modal_active: Map.has_key?(params, "action"),
      modal_context: Map.get(params, "action"),
      custom_error: nil,
      plans: Repo.all(from(Plan)),
      user_types: Repo.all(from(UserType))
    ) |> assign_form(User.user_changeset(%User{}, %{}))
    {
      :ok,
      socket
    }
  end

  def handle_event("showModal", %{ "selected" => user_id, "context" => context }, socket) do
    selected_user = Repo.get_by(User, id: elem(Integer.parse(user_id), 0))
                       |> Repo.preload([:plan, :user_type])

    socket =
      socket
         |> assign(:modal_active, !socket.assigns.modal_active)
         |> assign(:modal_context, context)
         |> assign(:selected_user, selected_user)
         |> assign_form(User.user_changeset(selected_user, %{}))
    {:noreply, socket}
  end

  def handle_event("view", %{ "selected" => uuid }, socket) do
    socket = socket
             |> redirect(to: "/admin/users/#{uuid}/dashboard")
    {:noreply, socket}
  end

  def handle_event("update", params, socket) do
    %{"user" => user} = params
    if Map.has_key?(user, "plan_id") do
      IO.inspect([socket.assigns.selected_user.id, user["plan_id"]], label: "CHANGINGPLAN")
      from(u in User, where: u.id == ^socket.assigns.selected_user.id, update: [set: [plan_id: ^user["plan_id"]]])
      |> Repo.update_all([])
    end

    if Map.has_key?(user, "user_type_id") do
      IO.inspect([socket.assigns.selected_user.id, user["user_type_id"]], label: "CHANGINGUSERTYPE")
      from(u in User, where: u.id == ^socket.assigns.selected_user.id, update: [set: [user_type_id: ^user["user_type_id"]]])
      |> Repo.update_all([])
    end

    socket = socket
             |> assign(trigger_submit: true)
             |> assign(:modal_active, !socket.assigns.modal_active)
             |> put_flash(:info, "User updated successfully.")
             |> redirect(to: ~p"/admin/users")

    {:noreply, socket}
  end

  def handle_event("delete", %{ "selected" => user_id}, socket) do
    try do
      us_id = elem(Integer.parse(user_id), 0)
      if socket.assigns.selected_user.user_type.user_type == "superuser" || socket.assigns.selected_user.user_type.user_type == "admin" do
        if socket.assigns.current_user.user_type.user_type == "superuser" do
          if socket.assigns.selected_user.user_type.user_type == "superuser" do
            socket = socket |> put_flash(:error, "You are not allowed to perform this action.")
                     |> assign(:modal_active, !socket.assigns.modal_active)
                     |> redirect(to: ~p"/admin/users")
            {:noreply, socket}
          else
            Repo.delete_all from(user in User, where: user.id == ^us_id)
            socket = socket |> put_flash(:info, "User deleted successfully.")
                     |> assign(:modal_active, !socket.assigns.modal_active)
                     |> redirect(to: ~p"/admin/users")
            {:noreply, socket}
          end
        else
          socket = socket |> put_flash(:error, "You are not allowed to perform this action.")
                   |> assign(:modal_active, !socket.assigns.modal_active)
                   |> redirect(to: ~p"/admin/users")
          {:noreply, socket}
        end
      else
        Repo.delete_all from(user in User, where: user.id == ^us_id)
        socket = socket |> put_flash(:info, "User deleted successfully.")
                 |> assign(:modal_active, !socket.assigns.modal_active)
                 |> redirect(to: ~p"/admin/users")
        {:noreply, socket}
      end
    catch
      message ->
        socket = socket
                 |> assign(:custom_error, message)
        {:noreply, socket}
    end
  end
end
