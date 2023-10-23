defmodule LiveEmailNotificationWeb.CreateGroup do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Create Group
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Creating group for user <%=@current_user.email %>.</p>
        </div>
        <.simple_form
          for={@form}
          id="create_group_form"
          phx-submit="create"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:group_name]} label="Group name" type="text" required />
          <.input field={@form[:group_description]} label="Group description" type="textarea" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Save group
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

