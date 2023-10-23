defmodule LiveEmailNotificationWeb.UpdateGroup do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Update Group
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Updating group.</p>
        </div>
        <.simple_form
          for={@form}
          id="update_group_form"
          phx-submit="update"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:id]} type="hidden" />
          <.input field={@form[:group_name]} label="Group name" type="text" required />
          <.input field={@form[:group_description]} label="Group description" type="textarea" placeholder="example@host.tld" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Update Group
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

