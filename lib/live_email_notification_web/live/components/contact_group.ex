defmodule LiveEmailNotificationWeb.ContactGroup do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  attr :parent_id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :contact, :any, default: nil
  attr :contact_groups, :list, default: []
  attr :callback, :any, required: true

  def render(assigns) do
    ~H"""
      <div>
        <div class="flex justify-between">
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
              <%=@title %>
            </h1>
            <p class="text-sm text-slate-500 hover:text-slate-600">Associating contact <%=@selected_contact.contact_email %> to group.</p>
          </div>
          <div>
            <button phx-click={@callback} type="button" class="inline-flex justify-center rounded-md text-sm font-semibold p-2 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center text-xs">Add Groups</span>
            </button>
          </div>
        </div>
        <.simple_form
          for={@form}
          id="create_contact_form"
          phx-submit="update-groups"
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
          <.input field={@form[:contact_name]} label="Contact name" type="text" />
          <.input field={@form[:contact_email]} label="Contact email" type="email" />
          <.input
            field={@form[:groups]}
            label="Groups (hold ⌘/Ctrl + select)"
            type="selectkv"
            options={@current_user.groups |> Enum.map(fn group -> %{id: group.id, name: group.group_name, selected: group.id in @contact_groups} end)}
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