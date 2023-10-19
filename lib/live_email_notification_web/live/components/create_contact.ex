defmodule LiveEmailNotificationWeb.CreateContact do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Create Contact
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Creating contact for user <%=@name %>.</p>
        </div>
        <.simple_form
          for={@form}
          id="create_contact_form"
          phx-submit="create_contact"
          phx-change="validate"
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:contact_name]} label="Contact name" type="text" placeholder="John Doe" class="block w-full rounded-md border-0 px-3.5 py-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-brand sm:text-sm sm:leading-6" required />
          <.input field={@form[:contact_email]} label="Contact email" type="email" placeholder="example@host.tld" class="block w-full rounded-md border-0 px-3.5 py-2 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-brand sm:text-sm sm:leading-6" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Save Contact
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

