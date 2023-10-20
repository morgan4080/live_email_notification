defmodule LiveEmailNotification.Db.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :uuid, Ecto.UUID, default: Ecto.UUID.generate()
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :msisdn, :string
    field :is_super, :boolean, default: false
    field :password, :string, virtual: true, redact: true
    field :password_confirmation, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :string

    belongs_to :plan, LiveEmailNotification.Db.Plan
    many_to_many :roles, LiveEmailNotification.Db.Role, join_through: "users_roles"
    has_many :contacts, LiveEmailNotification.Db.Contact
    has_many :groups, LiveEmailNotification.Db.Group
    has_many :emails, LiveEmailNotification.Db.Email
    timestamps(type: :utc_datetime)
  end

  @doc """
  Validate length for email and password.
    * `:hash_password` - Hashes the password
    * `:validate_email` - Validates the uniqueness of the email. Set option to false if not needed.
    * `:validate_msisdn` - Validates the uniqueness of the phone number. Set option to false if not needed.

  """

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :msisdn, :password, :password_confirmation])
    |> validate_email(opts)
    |> validate_msisdn(opts)
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> validate_confirmation(:password, message: "does not match password")
    |> maybe_hash_password(opts)
  end
  
  defp validate_msisdn(changeset, opts) do
    changeset
    |> validate_required([:msisdn])
    |> validate_format(:msisdn, ~r/^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}+$/, message: "Use a valid phone number")
    |> validate_length(:msisdn, max: 160)
    |> maybe_validate_unique_msisdn(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, LiveEmailNotification.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp maybe_validate_unique_msisdn(changeset, opts) do
    if Keyword.get(opts, :validate_msisdn, true) do
      changeset
      |> unsafe_validate_unique(:msisdn, LiveEmailNotification.Repo)
      |> unique_constraint(:msisdn)
    else
      changeset
    end
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
        # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
        # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end


  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
         %{changes: %{email: _}} = changeset -> changeset
         %{} = changeset -> add_error(changeset, :email, "did not change")
       end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Defaults to `true` set `false` if not required.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end


  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%LiveEmailNotification.Db.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
  
end