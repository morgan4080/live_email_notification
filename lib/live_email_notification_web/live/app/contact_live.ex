defmodule LiveEmailNotificationWeb.ContactLive do
  use LiveEmailNotificationWeb, :live_view

#  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Contact}

  import Ecto.Changeset

  def render(assigns) do
    ~H"""
      <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 space-y-1 lg:px-8">
        <div class="flex justify-between">
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
              <.link href={~p"/users/settings"} class="text-brand"><%= @current_user.first_name <> "'s" %></.link> <%= String.split(@current_path, "/") %>
            </h1>
            <p class="text-sm text-slate-500 hover:text-slate-600">View and add contacts to your account.</p>
          </div>
          <div>
            <button phx-click="showModal" type="button" class="inline-flex justify-center rounded-lg text-sm font-semibold py-2 px-3 bg-slate-900 text-white hover:bg-slate-700">
              <span class="flex items-center">Add Contact <span class="ml-3" aria-hidden="true"><Heroicons.Solid.book_open class="h-4 w-4" /></span></span>
            </button>
          </div>
        </div>
        <.table id="contacts" rows={@current_user.contacts}>
          <:col :let={contact} label="Contact Name"><%= contact.contact_name %></:col>
          <:col :let={contact} label="Contact Email"><%= contact.contact_email %></:col>
          <:col :let={contact} label="Actions"><%= contact.id %></:col>
        </.table>
        <.modal :if={@modal_active} id="contact-modal" show on_cancel={JS.navigate(~p"/contacts")}>
          <div>
            <div>
              <h1 class="text-2xl font-bold tracking-tight text-gray-900 capitalise">
                Create Contact
              </h1>
              <p class="text-sm text-slate-500 hover:text-slate-600">Creating contact for user <%=@current_user.email %>.</p>
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
        </.modal>
      </div>
    """
  end

  # <.live_component module={LiveEmailNotificationWeb.CreateContact} id="create_contact" form={@form} name={@current_user.email} />

  def assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "contact")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false, modal_active: false, page_title: "Contact")
      |> assign_form(contact_changeset(%Contact{}, %{}))

    IO.inspect(socket.assigns.form, label: "SOCKET_FORM")

    {:ok, socket}
  end

  def validate_email(changeset, _opts) do
    IO.inspect(changeset, label: "VALIDATING")
    changeset
    |> validate_required([:contact_email])
    |> validate_format(:contact_email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:contact_email, max: 160)
  end

  def validate_name(changeset, _opts) do
    changeset
    |> validate_required([:contact_name])
  end

  def contact_changeset(contact, attrs \\ %{}, opts \\ []) do
    contact
    |> cast(attrs, [:contact_name, :contact_email])
    |> validate_email(opts)
    |> validate_name(opts)
  end

  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = contact_changeset(
      %Contact{},
      contact_params
    )
    socket = socket |> assign_form(Map.put(changeset, :action, :validate)) |>  assign(trigger_submit: true)
    {:noreply, socket}
  end

  def handle_event("create_contact", %{"contact" => contact_params}, socket) do
    IO.inspect(contact_params)
    case %Contact{
           contact_name: Map.get(contact_params, "contact_name"),
           contact_email: Map.get(contact_params, "contact_email")
         }
         |> contact_changeset(contact_params)
         |> Repo.insert() do
      {:ok, contact} ->
        changeset = contact_changeset(contact, %{})
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("showModal", _, socket) do
    modal_active = !socket.assigns.modal_active
    socket = assign(socket, :modal_active, modal_active)
    {:noreply, socket}
  end
end
