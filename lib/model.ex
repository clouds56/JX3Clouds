defmodule Model do
  defmodule Repo do
    use Ecto.Repo, otp_app: :jx3replay
  end

  defmodule Person do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:person_id, :string, autogenerate: false}
    schema "persons" do
      # globalId, passportId, personId
      # personInfo: { bodyType, force, gameGlobalRoleId, gameRoleId, miniAvatar, passportId, person: {avatarUrl, id, nickName, signature}, roleName, server, zone }
      # rankNum, score, upNum, winRate
      field :passport_id, :string
      field :name, :string
      field :avatar, :string
      field :signature, :string
      timestamps()

      @permitted ~w(passport_id name avatar signature)a

      def changeset(person, change \\ :empty) do
        change = change
        |> Enum.filter(fn {_, v} -> v != nil end)
        |> Enum.into(%{})
        cast(person, change, @permitted)
      end
    end
  end

  defmodule Role do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:global_id, :string, autogenerate: false}
    schema "roles" do
      field :role_id, :id
      field :name, :string
      field :force, :string
      field :body_type, :string
      field :camp, :string
      field :zone, :string
      field :server, :string
      belongs_to :person, Person, type: :string
      timestamps()

      @permitted ~w(role_id name force body_type camp zone server person_id)a

      def changeset(role, change \\ :empty) do
        change = change
        |> Enum.filter(fn {_, v} -> v != nil end)
        |> Enum.into(%{})
        cast(role, change, @permitted)
      end
    end
  end

  defmodule RoleIndicator do
    use Ecto.Schema
    schema "indicators" do
      field :score, :integer
      belongs_to :role, Role
    end
  end

  defmodule Query do
    def update_person(%{person_id: id} = person) do
      p = case Repo.get(Person, id) do
        nil -> %Person{person_id: id}
        person -> person
      end
      p |> Person.changeset(person) |> Repo.insert_or_update
    end

    def update_role(%{global_id: id} = role) do
      r = case Repo.get(Role, id) do
        nil -> %Role{global_id: id}
        role -> role
      end
      r |> Role.changeset(role) |> Repo.insert_or_update
    end
  end
end