defmodule Jx3App.GraphQL do
  defmodule Schema.Role do
    use Absinthe.Schema.Notation

    object :role do
      field :name, :string
      field :role_id, :integer
      field :zone, :string
      field :server, :string
      field :camp, :string
      field :force, :string
      field :body_type, :string
    end
  end

  defmodule Resolvers do
    import Ecto.Query
    alias Jx3App.Model
    def roles(_, args, _) do
      limit = args[:limit] || 200
      offset = args[:offset] || 0
      roles = Model.Repo.all(from r in Model.Role,
        limit: ^limit,
        offset: ^offset)
      {:ok, roles}
    end
  end

  defmodule Schema do
    use Absinthe.Schema
    import_types Schema.Role

    query do
      @desc "Get all roles"
      field :roles, list_of(:role) do
        arg :limit, :integer, default_value: 200
        arg :offset, :integer, default_value: 0
        complexity fn %{limit: limit}, child_complexity ->
          limit * child_complexity
        end
        resolve &Resolvers.roles/3
      end
    end
  end
end
