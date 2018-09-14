defmodule Jx3App.Model.Match do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jx3App.Model.{MatchRole}

  @primary_key {:match_id, :integer, autogenerate: false}
  schema "matches" do
    field :start_time, :integer
    field :duration, :integer
    field :pvp_type, :integer
    field :map, :integer
    field :grade, :integer
    field :team1_score, :integer
    field :team2_score, :integer
    field :team1_kungfu, {:array, :integer}
    field :team2_kungfu, {:array, :integer}
    field :role_ids, {:array, :string}
    field :winner, :integer
    has_many :roles, MatchRole, foreign_key: :match_id

    timestamps(updated_at: false)
  end

  @permitted ~w(start_time duration pvp_type map grade team1_score team2_score team1_kungfu team2_kungfu role_ids winner)a

  def fix_role_ids(%{role_ids: _} = match), do: match
  def fix_role_ids(%{roles: roles} = match) do
    Map.put(match, :role_ids, roles |> Enum.map(fn %{global_id: id} -> id end))
  end

  def fix_pvptype(%{match_type: t} = change) do
    pvp_type = cond do
      is_integer(t) -> t
      is_binary(t) and Integer.parse(t) != :error -> {x, _} = Integer.parse(t); x
      true -> 0
    end
    Map.put(change, :pvp_type, pvp_type)
  end
  def fix_pvptype(change), do: change

  def valid_match_type?(%{match_type: match_type}), do: valid_match_type?(match_type)
  def valid_match_type?(match_type) do
    case Integer.parse(match_type) do
      {x, y} when x in [2, 3, 5] and y in ["c", "d", "m"] -> true
      _ -> false
    end
  end
  def prefix(match_type) do
    if valid_match_type?(match_type) do
      "match_#{match_type}"
    end
  end

  def subquery(match_type) do
    Ecto.Query.subquery(__MODULE__, prefix: prefix(match_type))
  end

  def changeset(match, change \\ :empty) do
    change = change
    |> fix_pvptype
    |> fix_role_ids
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    cast(match, change, @permitted)
  end
end

defmodule Jx3App.Model.MatchLog do
  alias Jx3App.Model.Match
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "match_logs" do
    belongs_to :match, Match, references: :match_id, primary_key: true
    field :replay, :map

    timestamps(updated_at: false)
  end

  @permitted ~w(replay)a

  def subquery(match_type) do
    Ecto.Query.subquery(__MODULE__, prefix: Match.prefix(match_type))
  end

  def changeset(log, change \\ :empty) do
    change = change
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    cast(log, change, @permitted)
  end
end
