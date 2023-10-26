defmodule LiveEmailNotificationWeb.ChangePermission do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  alias Phoenix.LiveView.JS


  attr :form, :any, required: true
  attr :user_types, :any, required: true
  attr :parent_id, :string, required: true
  attr :title, :string, default: "Change user permission"
  attr :message, :string, default: "message"
  attr :error, :string, default: nil
  attr :subject, :string, default: "SUBJECT"
  attr :subject_id, :string, default: "SUBJECT_ID"

  def render(assigns) do
    ~H"""
      <div>
        <.simple_form
          for={@form}
          id="update_user_form"
          phx-submit="update"
          phx-trigger-action={@trigger_submit}
        >
          <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4 -mt-9">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-slate-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-slate-600" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 5.25a3 3 0 013 3m3 0a6 6 0 01-7.029 5.912c-.563-.097-1.159.026-1.563.43L10.5 17.25H8.25v2.25H6v2.25H2.25v-2.818c0-.597.237-1.17.659-1.591l6.499-6.499c.404-.404.527-1 .43-1.563A6 6 0 1121.75 8.25z"></path>
                </svg>
              </div>
              <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                <h3 class="text-base font-semibold leading-6 text-gray-900" id="modal-title"><%= @title %></h3>
                <div class="mt1">
                  <small class="text-gray-400">
                    <%= @subject %>
                  </small>
                </div>
                <div class="mt-2">
                  <.error :if={@error}>
                    <%= @error %>
                  </.error>
                  <p :if={@error == nil} class="text-sm text-gray-500"><%= @message %></p>
                </div>
                <ul role="list" class="divide-y divide-gray-100">
                  <li :for={type <- @user_types} class="flex justify-between gap-x-6 py-5">
                    <label for={"permission-#{type.id}"} class="flex min-w-0 gap-x-4">
                      <div class="min-w-0 flex-auto">
                        <p class="text-sm font-semibold leading-6 text-gray-900 capitalize">
                          <%=type.user_type%>
                        </p>
                      </div>
                    </label>
                    <div class="shrink-0 flex flex-col items-end">
                      <.input field={@form[:user_type_id]} type="radio" id={"permission-#{type.id}"} value={type.id} checked={@form[:user_type_id].value == type.id} class="mt-3 text-brand ring-brand/25 ring-2" />
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <:actions>
            <div class="bg-gray-50 rounded-b-2xl px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6 w-full">
              <.button phx-disable-with="Sending..." class="inline-flex w-full justify-center rounded-md bg-green-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500 sm:ml-3 sm:w-auto">Change Permission</.button>
              <button phx-click={JS.exec("data-cancel", to: "##{@parent_id}")} type="button" class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto">Cancel</button>
            </div>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

# <.input field={@form[:user_type_id]} type="text" />
# <%=@form.id%>