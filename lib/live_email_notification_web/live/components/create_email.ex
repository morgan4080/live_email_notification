defmodule LiveEmailNotificationWeb.CreateEmail do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Create Email
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Creating email for user <%=@current_user.first_name %> <%=@current_user.last_name %>.</p>
        </div>
        <.simple_form
          for={@form}
          id="create_email_form"
          phx-submit="create"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:subject]} label="Subject" type="text" placeholder="Newsletter" required />
          <.input field={@form[:content]} label="Content" type="textarea" placeholder="Content" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Save Email
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

