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

  defmodule Match do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key {:match_id, :integer, autogenerate: false}
    schema "matches" do
      field :start_time, :integer
      field :duration, :integer
      field :pvp_type, :integer
      field :map, :integer
      field :grade, :integer
      field :total_score1, :integer
      field :total_score2, :integer
      field :team1, {:array, :integer}
      field :team2, {:array, :integer}
      field :winner, :integer

      timestamps(updated_at: false)
    end

    @permitted ~w(start_time duration pvp_type map total_score1 total_score2 team1 team2 winner)a

    def changeset(match, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(match, change, @permitted)
    end
  end

  defmodule MatchRole do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key false
    schema "match_roles" do
      belongs_to :match, Match, primary_key: true
      belongs_to :role, Role, type: :string, primary_key: true
      field :kungfu, :integer
      field :score, :integer
      field :score2, :integer
      field :ranking, :integer
      field :equip_score, :integer
      field :equip_addition_score, :integer
      field :max_hp, :integer
      field :metrics, {:array, :float}
      field :equips, {:array, :integer}
      field :talents, {:array, :integer}

      timestamps(updated_at: false)
    end

    @permitted ~w(kungfu score score2 ranking equip_score equip_addition_score max_hp metrics equips talents)a

    def changeset(role, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(role, change, @permitted)
    end
  end

  defmodule MatchLog do
    use Ecto.Schema
    import Ecto.Changeset
    @primary_key false
    schema "match_logs" do
      belongs_to :match, Match, primary_key: true
      field :replay, :map

      timestamps(updated_at: false)
    end

    @permitted ~w(replay)a

    def changeset(log, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(log, change, @permitted)
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

    def get_role(id) do
      Repo.get(Role, id)
    end

    def insert_performance(perf) do
      %RolePerformance{} |> RolePerformance.changeset(perf) |> Repo.insert_or_update
    end

    def insert_match(%{match_id: id, roles: roles} = match) do
      case Repo.get(Match, id) do
        nil ->
          multi = Ecto.Multi.new
          |> Ecto.Multi.insert(:match, %Match{match_id: id} |> Match.changeset(match))
          Enum.reduce(roles, multi, fn r, multi ->
            role_id = Map.get(r, :global_id)
            multi |> Ecto.Multi.insert("roles#{role_id}", %MatchRole{match_id: id, role_id: role_id} |> MatchRole.changeset(r))
          end)
          |> Repo.transaction
        role -> role
      end
    end

    def insert_match_log(%{"match_id" => id} = log) do
      case Repo.get(MatchLog, id) do
        nil -> %MatchLog{match_id: id} |> MatchLog.changeset(%{replay: log}) |> Repo.insert_or_update
        log -> log
      end
    end
  end
end