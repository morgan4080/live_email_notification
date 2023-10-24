defmodule LiveEmailNotificationWeb.UpdateEmail do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Update Email
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Updating email.</p>
        </div>
        <.simple_form
          for={@form}
          id="update_email_form"
          phx-submit="update"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:id]} type="hidden" />
          <.input field={@form[:subject]} label="Subject" type="text" required />
          <.input field={@form[:content]} label="Content" type="textarea" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Update Email
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

