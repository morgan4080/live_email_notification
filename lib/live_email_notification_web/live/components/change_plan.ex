defmodule LiveEmailNotificationWeb.ChangePlan do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  alias Phoenix.LiveView.JS

  attr :form, :any, required: true
  attr :parent_id, :string, required: true
  attr :title, :string, default: "Change user plan"
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
              <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-green-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z"></path>
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
                  <p :if={@error == nil} class="text-sm text-gray-500">
                    <%= @message %>
                  </p>
                </div>
                <ul role="list" class="divide-y divide-gray-100">
                  <li :for={plan <- @plans} class="flex items-start py-5 relative">
                    <label for={"plan-#{plan.id}"} class="leading-6 flex-1 min-w-0 gap-x-4">
                      <div class="min-w-0 flex-auto">
                        <p class="text-sm font-semibold leading-6 text-gray-900 capitalize">
                          <%=plan.plan_name%>
                        </p>
                        <p class="mt-1 truncate text-xs leading-5 text-gray-500">
                          <%=plan.plan_description%>
                          <%=@form[:plan_id].value == plan.id%>
                        </p>
                      </div>
                    </label>
                    <div class="ml-4">
                      <.input field={@form[:plan_id]} type="radio" id={"plan-#{plan.id}"} checked={@form[:plan_id].value == plan.id} value={plan.id} class="mt-3 text-brand ring-brand/25 ring-2" />
                    </div>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <:actions>
            <div class="w-full bg-gray-50 rounded-b-2xl px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
              <.button phx-disable-with="Sending..." class="inline-flex w-full justify-center rounded-md bg-green-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500 sm:ml-3 sm:w-auto">Change Plan</.button>
              <button phx-click={JS.exec("data-cancel", to: "##{@parent_id}")} type="button" class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto">Cancel</button>
            </div>
          </:actions>
        </.simple_form>
      </div>
    """
  end
end

