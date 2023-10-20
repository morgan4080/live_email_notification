defmodule LiveEmailNotificationWeb.UpdateContact do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Update Contact
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Updating contact.</p>
        </div>
        <.simple_form
          for={@form}
          id="update_contact_form"
          phx-submit="update"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:id]} type="hidden" />
          <.input field={@form[:contact_name]} label="Contact name" type="text" required />
          <.input field={@form[:contact_email]} label="Contact email" type="email" placeholder="example@host.tld" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Update Contact
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

