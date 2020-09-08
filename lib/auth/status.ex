defmodule Auth.Status do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "status" do
    field :text, :string
    field :desc, :string
    belongs_to :person, Auth.Person

    timestamps()
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:text, :desc])
    |> validate_required([:text])
  end

  def create_status(attrs, person) do
    %Status{}
    |> changeset(attrs)
    |> put_assoc(:person, person)
    |> Repo.insert!()
  end

  def upsert_status(attrs) do
    case Auth.Repo.get_by(__MODULE__, text: Map.get(attrs, "text")) do
      # create status
      nil ->
        email = System.get_env("ADMIN_EMAIL")
        person = Auth.Person.get_person_by_email(email)
        create_status(attrs, person)

      status ->
        status
    end
  end

  def list_statuses do
    Repo.all(__MODULE__)
  end
end
