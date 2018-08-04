defmodule Model do

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
    end
  end

  defmodule RoleIndicator do
    use Ecto.Schema
    schema "indicators" do
      field :score, :integer
      belongs_to :role, Role
    end
  end
end