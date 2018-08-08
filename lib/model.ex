defmodule Model do
  defmodule Repo do
    use Ecto.Repo, otp_app: :jx3replay
  end

  defmodule Person do
    use Ecto.Schema
    schema "persons" do
      # globalId, passportId, personId
      # personInfo: { bodyType, force, gameGlobalRoleId, gameRoleId, miniAvatar, passportId, person: {avatarUrl, id, nickName, signature}, roleName, server, zone }
      # rankNum, score, upNum, winRate
      field :person_id, :string
      field :passport_id, :string
      field :name, :string
      field :avatar, :string
      field :signature, :string
    end
  end

  defmodule Role do
    use Ecto.Schema
    import Ecto.Changeset
    schema "roles" do
      field :role_id, :id
      field :global_id, :string
      field :name, :string
      field :force, :string
      field :body_type, :string
      field :camp, :string
      field :zone, :string
      field :server, :string
      belongs_to :person, Person

      @permitted ~w(role_id global_id name force body_type camp zone server person)a

      def changeset(role, change \\ :empty) do
        role |> cast(change, @permitted)
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
    def update_role(%{global_id: id} = role) do
      r = case Repo.get(Role, id) do
        nil -> %Role{global_id: id}
        role -> role
      end
      r |> Role.changeset(role) |> Repo.insert_or_update
    end
  end
end