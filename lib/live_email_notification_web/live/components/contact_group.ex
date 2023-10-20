defmodule LiveEmailNotificationWeb.ContactGroup do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  attr :parent_id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :contact, :any, default: nil

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            <%=@title %>
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Associating contact <%=@selected_contact.contact_email %> to group.</p>
        </div>
        <.simple_form
          for={@form}
          id="create_contact_form"
          phx-submit="create"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.input field={@form[:contact_name]} label="Contact name" type="text" placeholder="John Doe" disabled />
          <.input field={@form[:contact_email]} label="Contact email" type="email" placeholder="example@host.tld" disabled />
          <.input field={@form[:group]} label="Group" type="select" options={@current_user.groups} required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Associate
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end