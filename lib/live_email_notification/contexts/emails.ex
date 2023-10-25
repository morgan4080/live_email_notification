defmodule LiveEmailNotification.Contexts.Emails do
  import Ecto.Query
  alias LiveEmailNotification.Repo
  alias LiveEmailNotification.Db.{Email,Contact, Group}
  alias LiveEmailNotification.Contexts.Jobs.SendEmailJob
  alias LiveEmailNotification.Helpers.Converter

  def get_email_by_id(email_id) do
    Repo.get_by!(Email, id: email_id)
  end

  def get_user_by_email_id(id) do
    email = Repo.get_by!(Email, id: id) |> Repo.preload([:user])
    email.user
  end

  def upsert_email_contacts(email, changes) do
    contacts = Contact |> where([c], c.id in ^changes.contacts) |> Repo.all()
    update = Email.changeset_update_contacts(email, contacts, %{ "subject" => changes.subject, "content" => changes.content }) |> Repo.update()
    case update do
      {:ok, email_struct} ->
        # if no contacts no jobs start
        Enum.map(contacts, fn contact ->
          %{
            "email_id" => email.id,
            "contact_id" => contact.id,
            "contact_name" => contact.contact_name,
            "destination_email" => contact.contact_email,
            "subject" => changes.subject,
            "content" => changes.content
          } |> SendEmailJob.new() |> Oban.insert()
        end)
        {:ok, email_struct}
      _ ->
        {:error, "Unable to update and send emails."}
    end
  end

  def update_email(email_params) do
    try do
      %{"id" => id, "subject" => subject, "content" => content} = email_params
      e_id = elem(Integer.parse(id), 0)
      from(email in Email, where: email.id == ^e_id, update: [set: [subject: ^subject, content: ^content]])
      |> Repo.update_all([])

      {:ok, "Email updated successfully."}
    catch
      message ->
        {:error, message}
    end
  end

  def delete_email(email_id) do
    try do
      em_id = elem(Integer.parse(email_id), 0)
      Repo.delete_all from(email in Email, where: email.id == ^em_id)
      {:ok, "Email deleted successfully."}
    catch
      message ->
        {:error, message}
    end
  end

  def create_email(email_params, user) do
      %{"subject" => subject, "content" => content} = email_params

      email = %Email{subject: subject, content: content, user_id: user.id, contacts: []}

      email_changeset = Email.email_changeset(email, email_params)

      if email_changeset.valid? do
        try do
          {:ok, Repo.insert!(email_changeset)}
        catch
          message ->
            {:error, message}
        end
      else
        {:error, "Invalid check. Email creation failed"}
      end
  end

  def validate_email(email_params) do
    if Map.has_key?(email_params, "contacts") do
      contact_ids = email_params["contacts"]
      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)
      contacts = Repo.all(from c in Contact,
                          where: c.id in ^selected_contacts_ints,
                          select: c) |> Repo.preload([:groups, :emails])

      contacts_map = Enum.map(contacts, fn contact ->
        Map.from_struct(%{contact | groups: [], emails: []})
      end)

      changes = %{email_params | "contacts" => contacts_map}

      changeset = Email.email_changeset(
        %Email{},
        changes
      )
      {
        :ok,
        %{
          "changeset" => changeset,
          "bulk" => Enum.map([email_params["is_bulk"]], &Converter.convert!/1) |> List.last(),
          "selected_email_group_contacts" => []
        }
      }
    else
      if Map.has_key?(email_params, "groups") do
        group_ids = email_params["groups"]
        selected_groups_ints = Enum.map(group_ids, fn group -> elem(Integer.parse(group), 0) end)
        groups = Repo.all(from g in Group,
                          where: g.id in ^selected_groups_ints,
                          select: g) |> Repo.preload([:contacts])
        contacts_lists = Enum.flat_map(groups, fn group ->
          Enum.map(group.contacts, fn contact ->
            Map.from_struct(contact)
          end)
        end)

        changeset = Email.email_changeset(
          %Email{},
          email_params
        )
        {
          :ok,
          %{
            "changeset" => changeset,
            "bulk" => Enum.map([email_params["is_bulk"]], &Converter.convert!/1) |> List.last(),
            "selected_email_group_contacts" => Enum.uniq(contacts_lists)
          }
        }
      else
        changeset = Email.email_changeset(
          %Email{},
          email_params
        )

        if Map.has_key?(email_params, "is_bulk") do
          {
            :ok,
            %{
              "changeset" => changeset,
              "bulk" => Enum.map([email_params["is_bulk"]], &Converter.convert!/1) |> List.last(),
              "selected_email_group_contacts" => []
            }
          }
        else
          {
            :ok,
            %{
              "changeset" => changeset,
              "bulk" => false,
              "selected_email_group_contacts" => []
            }
          }
        end
      end
    end
  end

  def send_and_update_email(email_params, selected_email_group_contacts, live_action, selected_user_id, current_user_id) do
    if Map.has_key?(email_params, "contacts") do
      contact_ids = email_params["contacts"]

      selected_contacts_ints = Enum.map(contact_ids, fn contact -> elem(Integer.parse(contact), 0) end)

      %{"content" => content, "id" => email_id, "subject" => subject, "contacts" => contacts} = %{email_params | "contacts" => selected_contacts_ints}
      email_changes = if live_action == :admin do
        # selected_user user exists through uuid TODO UUID
        # when live_action == :admin
        Map.put_new(%Email{subject: subject, content: content, contacts: contacts}, :user_id, selected_user_id)
      else
        Map.put_new(%Email{subject: subject, content: content, contacts: contacts}, :user_id, current_user_id)
      end

      email = Repo.get_by(Email, id: elem(Integer.parse(email_id), 0)) |> Repo.preload([:contacts])

      {:ok, %{"email" => email, "email_changes" => email_changes, "message" => "Contacts associated successfully."}}
    else
      if Map.has_key?(email_params, "groups") do
        group_ids = email_params["groups"]
        # no need for fetching contacts from groups again because they exist in socket.assigns.selected_email_group_contacts from validation
        %{
          "content" => content,
          "id" => email_id,
          "subject" => subject,
          "contacts" => contacts
        } = if length(selected_email_group_contacts) > 0 do
              Map.put_new(email_params, "contacts", Enum.map(selected_email_group_contacts, fn  contact -> contact.id end))
            else
              # when selected_email_group_contacts is empty
              selected_groups_ints = Enum.map(group_ids, fn group -> elem(Integer.parse(group), 0) end)
              groups = Repo.all(from g in Group,
                                where: g.id in ^selected_groups_ints,
                                select: g) |> Repo.preload([:contacts])
              contacts_lists = Enum.flat_map(groups, fn group ->
                Enum.map(group.contacts, fn contact ->
                  Map.from_struct(contact.id)
                end)
              end)

              Map.put_new(email_params, "contacts", Enum.uniq(contacts_lists))
            end

        email_changes = if live_action == :admin do
          # selected_user user exists through uuid TODO UUID
          # live_action == :admin
          Map.put_new(%Email{subject: subject, content: content, contacts: contacts}, :user_id, selected_user_id)
        else
          Map.put_new(%Email{subject: subject, content: content, contacts: contacts}, :user_id, current_user_id)
        end

        email = Repo.get_by(Email, id: elem(Integer.parse(email_id), 0)) |> Repo.preload([:contacts])

        {:ok, %{"email" => email, "email_changes" => email_changes, "message" => "Group contacts associated successfully."}}
      else

        %{ "id" => email_id, "content" => content, "subject" => subject } = email_params

        email_changes = if live_action == :admin do
          # selected_user user exists through uuid
          # when socket.assigns.live_action == :admin
          Map.put_new(%Email{subject: subject, content: content, contacts: []}, :user_id, selected_user_id)
        else
          Map.put_new(%Email{subject: subject, content: content, contacts: []}, :user_id, current_user_id)
        end

        email = Repo.get_by(Email, id: elem(Integer.parse(email_id), 0)) |> Repo.preload([:contacts])

        {:ok, %{"email" => email, "email_changes" => email_changes, "message" => "Contacts disassociated successfully."}}
      end
    end
  end

end