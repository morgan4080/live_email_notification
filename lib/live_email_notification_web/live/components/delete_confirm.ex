defmodule LiveEmailNotificationWeb.DeleteConfirm do
  use Phoenix.LiveComponent

  import LiveEmailNotificationWeb.CoreComponents

  alias Phoenix.LiveView.JS


  attr :parent_id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :subject, :string, required: true #contact.contact_email
  attr :subject_id, :string, required: true #contact.id

  def render(assigns) do
    ~H"""
      <div>
        <div class="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
          <div class="sm:flex sm:items-start">
            <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
              <svg class="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
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
            </div>
          </div>
        </div>
        <div class="bg-gray-50 rounded-b-2xl px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
          <button phx-click="delete" phx-value-selected={@subject_id} type="button" class="inline-flex w-full justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:ml-3 sm:w-auto">Delete</button>
          <button phx-click={JS.exec("data-cancel", to: "##{@parent_id}")} type="button" class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto">Cancel</button>
        </div>
      </div>
    """
  end
end

