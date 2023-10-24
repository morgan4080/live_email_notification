defmodule LiveEmailNotificationWeb.SendEmail do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  def render(assigns) do
    ~H"""
      <div>
        <div>
          <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
            Send Email
          </h1>
          <p class="text-sm text-slate-500 hover:text-slate-600">Updating email.</p>
        </div>
        <.simple_form
          for={@form}
          id="update_email_form"
          phx-submit="send-email"
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
          <.input field={@form[:is_bulk]} label="Send bulk emails" type="checkbox" />
          <.input
            :if={!@bulk}
            field={@form[:contacts]}
            label="Contacts (hold ⌘/Ctrl + select)"
            type="selectkv"
            options={@current_user.contacts |> Enum.map(fn contact -> %{id: contact.id, name: contact.contact_name, selected: contact.id in @email_contacts} end)}
            multiple
            required
          />
          <div :if={@bulk} class="grid grid-cols-2 gap-4">
            <.input
              field={@form[:groups]}
              label="Groups (hold ⌘/Ctrl + select)"
              type="selectkv"
              options={@current_user.groups |> Enum.map(fn group -> %{id: group.id, name: group.group_name, selected: false} end)}
              multiple
              required
            />
            <.input
              field={@form[:selected_email_group_contacts]}
              label="Group Contacts"
              type="selectkv"
              options={@selected_email_group_contacts |> Enum.map(fn contact -> %{id: contact.id, name: contact.contact_name, selected: true} end)}
              multiple
              required
              disabled
              class="bg-gray-200"
            />
          </div>
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full">
              Send Email
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

