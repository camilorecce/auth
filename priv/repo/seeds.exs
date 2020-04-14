# Script for populating the database. You can run it as:
#
# mix run priv/repo/seeds.exs
#
# The seeds.exs script will also run
# when you execute the following command
# to setup the database:
#
# mix ecto.setup
defmodule Auth.Seeds do
  alias Auth.{Person, Repo, Status}
  import Ecto.Changeset # put_assoc
  # IO.inspect(System.get_env("ADMIN_EMAIL"), label: "ADMIN_EMAIL")

  def create_admin do
    email = System.get_env("ADMIN_EMAIL")

    person = case Person.get_person_by_email(email) do
      nil ->
        %Person{email: email}
        |> Person.changeset(%{email: email})
        |> put_assoc(:statuses, [%Status{text: "verified"}])
        |> Repo.insert!()
        # |> IO.inspect( label: "inserted")

      person ->
        person
    end

    IO.inspect(person.id, label: "seeds.exs person.id")
    IO.puts("- - - - - - - - - - - - - - - - - - - - - - ")
  end
end

Auth.Seeds.create_admin()
