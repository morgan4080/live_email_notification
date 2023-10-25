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
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={@form[:id]} type="hidden" />
          <.input field={@form[:subject]} label="Subject" type="text" required />
          <.input field={@form[:content]} label="Content" type="textarea" required />
          <.input field={@form[:is_bulk]} label="Send bulk emails" type="checkbox" />
          <span :if={length(@email_contacts) > 0} class="group items-center gap-2 rounded-full bg-white/25 px-3 py-2 text-xs text-slate-900 ring-1 ring-inset ring-black/[0.08] hover:bg-white/50 hover:ring-black/[0.13] flex mt-6">
              <Heroicons.Outline.information_circle class="h-4 w-4 text-brand" />
              <span class="font-medium">
                <span>Highlighted contacts have already been sent this email.
                  <button phx-click={@callbackstatus} class="border-b border-brand">Check statuses</button>
                </span>
              </span>
          </span>
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

