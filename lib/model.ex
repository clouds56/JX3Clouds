defmodule Jx3App.Model do
  alias Jx3App.Model.{Item, Person, Role, RoleLog, RolePerformance, RolePerformanceLog, Match, MatchRole, MatchLog}

  defmodule Repo do
    use Ecto.Repo, otp_app: :jx3app

    defmodule LogEntry do
      def log(%{query: query} = entry) do
        cond do
          query =~ ~r/^SELECT .* FROM "(items|matches)" AS .*/ -> entry
          true -> Ecto.LogEntry.log(entry)
        end
      end
    end
  end

  defmodule AnyType do
    def type, do: :jsonb
    def load(i), do: {:ok, i}
    def cast(i), do: {:ok, i}
    def dump(i), do: {:ok, i}
  end

  defmodule DateRangeType do
    @behaviour Ecto.Type
    def type, do: :daterange
    def load(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.load/1)
    def load(_), do: :error
    def cast([lower, upper], opts) do
      lower_inclusive = case opts[:upper_inclusive] do
        nil -> true
        x -> x
      end
      upper_inclusive = opts[:upper_inclusive] || false
      cast(%Postgrex.Range{lower: lower, lower_inclusive: lower_inclusive, upper: upper, upper_inclusive: upper_inclusive})
    end
    def cast(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.cast/1)
    def cast([lower, upper]), do: cast([lower, upper], [])
    def cast(_), do: :error
    def dump(%Postgrex.Range{} = range), do: apply_range(range, &Ecto.Date.dump/1)
    def dump(_), do: :error
    def apply_range(%Postgrex.Range{lower: lower, upper: upper} = range, func) do
      func = fn nil -> {:ok, nil}; x -> func.(x) end
      case {func.(lower), func.(upper)} do
        {{:ok, lower}, {:ok, upper}} -> {:ok, %{range | lower: lower, upper: upper}}
        _ -> :error
      end
    end

    def in?(%Postgrex.Range{} = r, %Ecto.Date{} = i) do
      {:ok, r} = cast(r)
      cond do
        r.lower != nil and Ecto.Date.compare(i, r.lower) == :lt -> false
        r.lower != nil and r.lower_inclusive == false and Ecto.Date.compare(i, r.lower) == :eq -> false
        r.upper != nil and r.upper_inclusive != true and Ecto.Date.compare(i, r.upper) == :eq -> false
        r.upper != nil and Ecto.Date.compare(i, r.upper) == :eq -> false
        true -> true
      end
    end

    def compare(true, false), do: :gt
    def compare(false, true), do: :lt
    def compare(x, y) when is_boolean(x) and is_boolean(y) and x == y, do: :eq
    def compare(r1, r2) do
      r = [
        Ecto.Date.compare(r1.lower, r2.lower),
        compare(r2.lower_inclusive, r1.lower_inclusive),
        Ecto.Date.compare(r1.upper, r2.upper),
        compare(r2.upper_inclusive, r1.upper_inclusive),
      ] |> Enum.filter(&:eq != &1)
      case r do
        [i | _] -> i
        [] -> :eq
      end
    end
  end

  defmodule Query do
    import Ecto.Query

    def update_item(%{tag: tag, id: id} = item) do
      {tag, id} = {"#{tag}", "#{id}"}
      case Repo.get_by(Item, [tag: tag, id: id]) do
        nil -> %Item{tag: tag, id: id}
        item -> item
      end
      |> Item.changeset(item) |> Repo.insert_or_update
    end

    def get_items(tag \\ nil) do
      if tag do
        Repo.all(from i in Item, where: i.tag == ^tag)
      else
        Repo.all(from i in Item)
      end
      |> Enum.group_by(fn i -> i.tag end)
    end

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

    def insert_role_log(%{global_id: _} = role) do
      query = ~w(global_id name zone server)a
      |> Enum.map(&{&1, Map.get(role, &1) || ""})
      |> Keyword.put(:role_id, Map.get(role, :role_id) || 0)

      case Repo.get_by(RoleLog, query) do
        nil -> %RoleLog{} |> RoleLog.changeset(query)
        role -> role
      end |> RoleLog.changeset(role) |> Repo.insert_or_update
    end

    def get_role(id) do
      Repo.get(Role, id)
    end

    def get_roles(limit \\ 5000) do
      query = from(
        r in Role,
        left_join: s in RolePerformance,
        on: r.global_id == s.role_id,
        where: s.match_type == "3c",
        order_by: [fragment("? DESC NULLS LAST", s.score)],
        select: {r, s})
      case limit do
        :all -> query
        -1 -> query
        _ -> query |> limit(^limit)
      end
      Repo.all(query)
    end

    def update_performance(%{role_id: id, match_type: mt} = perf) do
      p = case Repo.get_by(RolePerformance, [role_id: id, match_type: mt]) do
        nil -> %RolePerformance{role_id: id, match_type: mt}
        p -> p
      end
      |> RolePerformance.changeset(perf) |> Repo.insert_or_update

      if Map.has_key?(perf, :score) do
        %RolePerformanceLog{} |> RolePerformanceLog.changeset(perf) |> Repo.insert
      end
      p
    end

    def insert_match(%{match_type: match_type, match_id: id, roles: roles} = match) do
      case Repo.get(Match, id, prefix: Match.prefix(match_type)) do
        nil ->
          multi = Ecto.Multi.new
          |> Ecto.Multi.insert(:match, %Match{match_id: id} |> Match.changeset(match), prefix: Match.prefix(match_type))
          {:ok, r} = Enum.reduce(roles, multi, fn r, multi ->
            role_id = Map.get(r, :global_id)
            multi |> Ecto.Multi.insert("role_#{role_id}", %MatchRole{match_id: id, role_id: role_id} |> MatchRole.changeset(r), prefix: Match.prefix(match_type))
          end)
          |> Repo.transaction
          {:ok, %{Map.get(r, :match) | roles: Enum.map(roles, fn i ->
            role_id = Map.get(i, :global_id)
            Map.get(r, "role_#{role_id}")
          end)}}
        match -> match
      end
    end

    def get_match(match_type, id) do
      Repo.get(Match, id, prefix: Match.prefix(match_type))
    end

    def get_matches(match_type) do
      Repo.all(from(m in Match, order_by: :match_id), prefix: Match.prefix(match_type))
    end

    def get_matches_by_role(match_type, id) do
      Repo.all(from(r in MatchRole, left_join: m in Match, on: r.match_id == m.match_id, where: r.role_id == ^id, order_by: m.start_time, select: m), prefix: Match.prefix(match_type))
    end

    def insert_match_log(%{"match_type" => type, "match_id" => id} = log) do
      case Repo.get(MatchLog, id, prefix: Match.prefix(type)) do
        nil -> %MatchLog{match_id: id} |> MatchLog.changeset(%{replay: log}) |> Repo.insert_or_update(prefix: Match.prefix(type))
        log -> log
      end
    end
  end
end
