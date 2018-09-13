defmodule Jx3App.Model.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jx3App.Model.{Person, RolePerformance}

  @primary_key {:global_id, :string, autogenerate: false}
  schema "roles" do
    field :role_id, :id
    field :passport_id, :string
    field :name, :string
    field :force, :string
    field :body_type, :string
    field :camp, :string
    field :zone, :string
    field :server, :string
    belongs_to :person, Person, type: :string, references: :person_id
    has_many :performances, RolePerformance, foreign_key: :role_id
    timestamps()

    @permitted ~w(role_id passport_id name force body_type camp zone server person_id)a

    def changeset(role, change \\ :empty) do
      change = change
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.into(%{})
      cast(role, change, @permitted)
    end
  end
end
