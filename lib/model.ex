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

  defmodule RolePerformance do
    use Ecto.Schema
    import Ecto.Changeset
    schema "indicators" do
      field :pvp_type, :integer
      field :score, :integer
      field :grade, :integer
      field :ranking, :integer
      field :total_count, :integer
      field :win_count, :integer
      field :mvp_count, :integer
      belongs_to :role, Role, type: :string

      timestamps(updated_at: false)
    end

    @permitted ~w(pvp_type score grade ranking total_count win_count mvp_count role_id)a

    def changeset(perf, change \\ :empty) do
      change = case change do
        %{ranking: r} -> %{change | ranking: cond do
          is_integer(r) -> r
          String.at(r, -1) == "%" -> r |> String.trim_trailing("%") |> String.to_integer |> Kernel.-
          true -> r |> String.to_integer
        end}
        change -> change
      end
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(perf, change, @permitted)
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

    def insert_performance(perf) do
      %RolePerformance{} |> RolePerformance.changeset(perf) |> Repo.insert_or_update
    end
  end
end