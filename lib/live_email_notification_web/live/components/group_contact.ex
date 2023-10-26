defmodule LiveEmailNotificationWeb.GroupContact do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  attr :parent_id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :group, :any, default: nil
  attr :group_contacts, :list, default: []
  attr :callback, :any, required: true

  def render(assigns) do
    ~H"""
      <div>
        <div class="flex justify-between">
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
              <%=@title %>
            </h1>
            <p class="text-sm text-slate-500 hover:text-slate-600">Associating group (<%=@selected_group.group_name %>: <%=@selected_group.group_description %>) to contacts.</p>
          </div>
        </div>
        <.simple_form
          for={@form}
          id="create_group_form"
          phx-submit="update-contacts"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          class="-mt-4"
        >
          <.error :if={@check_errors}>
            <%=if @custom_error do %>
              <%= @custom_error %>
            <% else %>
              Oops, something went wrong! Please check the errors below.
            <% end %>
          </.error>
          <.input field={@form[:id]} type="hidden" />
          <.input
            field={@form[:contacts]}
            label="Contacts (hold ⌘/Ctrl + select)"
            type="selectkv"
            options={@current_user.contacts |> Enum.map(fn contact -> %{id: contact.id, name: contact.contact_name, selected: contact.id in @group_contacts} end)}
            multiple
          />
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