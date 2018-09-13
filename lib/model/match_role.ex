defmodule Jx3App.Model.MatchRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jx3App.Model.{Match, Role, RolePerformance}

  @primary_key false
  schema "match_roles" do
    belongs_to :match, Match, references: :match_id, primary_key: true
    belongs_to :role, Role, type: :string, references: :global_id, primary_key: true
    field :kungfu, :integer
    field :score, :integer
    field :score2, :integer
    field :ranking, :integer
    field :equip_score, :integer
    field :equip_addition_score, :integer
    field :max_hp, :integer
    field :metrics_version, :integer
    field :metrics, {:array, :float}
    field :equips, {:array, :integer}
    field :talents, {:array, :integer}
    field :attrs_version, :integer
    field :attrs, {:array, :float}

    timestamps(updated_at: false)
  end

  @permitted ~w(kungfu score score2 ranking equip_score equip_addition_score max_hp
    metrics_version metrics equips talents attrs_version attrs)a

  def fix_attrs(%{attrs: attrs} = change) do
    attrs = attrs |> Enum.map(fn v -> {v, _} = Float.parse(v); v end)
    %{change | attrs: attrs}
  end
  def fix_attrs(change), do: change

  def subquery(match_type) do
    Ecto.Query.subquery(__MODULE__, prefix: Match.prefix(match_type))
  end

  def changeset(role, change \\ :empty) do
    change = change |> RolePerformance.fix_ranking
    |> fix_attrs
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    cast(role, change, @permitted)
  end
end
