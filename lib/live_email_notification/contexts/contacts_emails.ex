defmodule LiveEmailNotification.Contexts.ContactsEmails do

  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{ContactEmail}


  def get_contacts_email_by_email_id(email_id) do
    ContactEmail |> where([ce], ce.email_id == ^email_id) |> Repo.all()
  end

  def update_contact_email(%{"contact_id" => contact_id, "email_id" => email_id, "is_email_sent" => is_email_sent}) do
    contact_email = ContactEmail |> where([ce], ce.contact_id == ^contact_id and ce.email_id == ^email_id) |> Repo.one()
    ContactEmail.contacts_emails_changeset(contact_email, %{"is_email_sent" => is_email_sent})
      |> Repo.update()
  end

  def remove_contact_email(id) do
    Repo.delete_all from(ce in ContactEmail, where: ce.id == ^id)
  end
end