defmodule LiveEmailNotification.Contexts.Jobs.SendEmailJob do
  use Oban.Worker, queue: :mailers, max_attempts: 2, priority: 1

  require Logger
  import Swoosh.Email
  alias LiveEmailNotification.Contexts.{Emails, ContactsEmails}
  alias LiveEmailNotification.Mailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "email_id" => email_id,
    "contact_id" => contact_id,
    "contact_name" => contact_name,
    "destination_email" => destination_email,
    "subject" => subject,
    "content" => content
  }}) do
      user = Emails.get_user_by_email_id(email_id)

      email =
        new()
        |> to({contact_name, destination_email})
        |> from({"#{user.first_name}  #{user.last_name}" , user.email})
        |> subject(subject)
        |> text_body(content)

      case Mailer.deliver(email) do
        # update status of contacts_emails column is_email_sent to true
        {:ok, _metadata} ->
          ContactsEmails.update_contact_email(%{"contact_id" => contact_id, "email_id" => email_id, "is_email_sent" => true})
          {:ok, email}
        {:error, _error} ->
          # add failure reason
          ContactsEmails.update_contact_email(%{"contact_id" => contact_id, "email_id" => email_id, "is_email_sent" => true})
          {:ok, email}
      end
  end
end