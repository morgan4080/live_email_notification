defmodule LiveEmailNotification.Contexts.Jobs.SendEmailJob do
  use Oban.Worker, queue: :mailers, max_attempts: 2, priority: 3

  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "email" => email,
    "contact_id" => contact_id,
    "contact_name" => contact_name,
    "destination_email" => destination_email,
    "subject" => subject,
    "content" => content
  }}) do
      IO.inspect([email, contact_id, contact_name, destination_email, subject, content], label: "OBAN")
    :ok
  end
end