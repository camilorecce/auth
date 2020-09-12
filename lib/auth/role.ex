defmodule Auth.Role do
  @moduledoc """
  Defines roles schema and CRUD functions
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "roles" do
    field :desc, :string
    field :name, :string
    field :person_id, :id
    field :app_id, :id
    # many_to_many :roles, Auth.Role, join_through: Auth.PeopleRoles

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :desc, :person_id, :app_id])
    |> validate_required([:name, :desc])
  end

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(__MODULE__)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(__MODULE__, id)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def upsert_role(role) do
    id = Map.get(role, :id)
    # if the role Map has no "id" field its not a DB record
    if is_nil(id) do
      create_role(role)
    else
      case Repo.get_by(__MODULE__, id: id) do
        # record does not exist so create it:
        nil ->
          create_role(role)

        # record exists, lets update it:
        existing_role ->
          update_role(existing_role, strip_meta(role))
      end
    end
  end

  defp strip_meta(struct) do
    struct
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  # @doc """
  # grants the default "subscriber" (6) role to the person
  # """
  # def set_default_role(person) do
  # end
end
