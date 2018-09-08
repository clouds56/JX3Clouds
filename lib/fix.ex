defmodule Model.Fix do
  import Ecto.Query
  require Logger
  alias Model.Repo

  def fix_match_array_order do
    # TODO not only 3c
    Model.Query.get_matches("3c") |> Enum.each(fn m ->
      {:ok, _} = Model.Match.changeset(m, %{team1: Enum.sort(m.team1), team2: Enum.sort(m.team2)})
      |> Model.Repo.update
    end)
    :ok
  end

  def get_roles_of_match_grade_null do
    Repo.all(
      from m in Model.Match,
      left_join: r in Model.MatchRole,
      on: m.match_id == r.match_id,
      where: is_nil(m.grade) or m.grade == 0,
      select: r.role_id
    ) |> Enum.reduce(%{}, fn i, acc -> Map.update(acc, i, 1, &(&1 + 1)) end)
    |> Enum.sort_by(fn {_, v} -> v end, &>=/2)
  end

  def fix_match_grade_for_roles(roles) do
    client = Jx3APP.lookup()
    roles |> Enum.each(fn r ->
      size = Model.Query.get_matches_by_role("3c", r) |> Enum.count
      size = trunc(size * 1.1)
      Logger.info("fetching matches of #{r} of size #{size}")
      history = GenServer.call(client, {:role_history, r, 0, size})
      if size != Enum.count(history) do
        Logger.error("size != history.count (#{size} != #{Enum.count(history)}) [with global_id = #{r}]")
      end
      if history do
        history |> Enum.map(fn %{match_type: type, match_id: id} = m ->
          case Model.Query.get_match(type, id) do
            %Model.Match{grade: nil} = mm ->
              Model.Match.changeset(mm, %{grade: Map.get(m, :avg_grade)})
              |> Model.Repo.update
            _ -> :ok
          end
        end)
      end
    end)
    :ok
  end

  def fix_match_grade do
    Model.Query.get_roles
    |> Enum.filter(fn {_, r} -> r.fetch_at != nil end)
    |> Enum.map(fn {r, _} -> r.global_id end)
    |> fix_match_grade_for_roles

    get_roles_of_match_grade_null()
    |> Enum.map(fn {r, _} -> r end)
    |> Enum.take(10)
    |> fix_match_grade_for_roles
  end

  defimpl Inspect, for: Postgrex.Range do
    import Inspect.Algebra

    def inspect(range, _opts) do
      left = range.lower_inclusive && "[" || "("
      right = range.upper_inclusive && "]" || ")"
      concat(["#Postgrex.Range<", left, inspect(range.lower), ", ", inspect(range.upper), right, ">"])
    end
  end

  def fix_date_range(dr) do
    combine = fn y, x ->
      case Ecto.Date.compare(x.upper, y.upper) do
        :lt -> y
        :gt -> %{y | upper: x.upper, upper_inclusive: x.upper_inclusive}
        :eq -> %{y | upper_inclusive: x.upper_inlcusive || y.upper_inclusive}
      end
    end
    dr |> Enum.sort(fn i, j -> Model.DateRangeType.compare(i, j) in [:lt, :eq] end)
    |> Enum.reduce({[], nil},
      fn x, {acc, nil} -> {acc, x}
        x, {acc, y} ->
          case {Model.RoleLog.diff_date(x.lower, y.upper), x.lower_inclusive, y.upper_inclusive} do
            {i, _, _} when i < 0 -> {acc, combine.(y, x)}
            {0, true, false} -> {acc, combine.(y, x)}
            {0, false, true} -> {acc, combine.(y, x)}
            {i, true, true} when i <= 1 -> {acc, combine.(y, x)}
            _ -> {[y | acc], x}
          end
      end) |> (fn {acc, y} -> [y | acc] end).() |> Enum.reverse
  end

  def fix_role_logs do
    Repo.all(Model.RoleLog)
    |> Enum.filter(fn r -> length(r.seen) > 1 end)
    |> Enum.map(fn r ->
      fix_seen = fix_date_range(r.seen)
      if fix_seen != r.seen do
        Logger.warn("fix #{inspect(r.seen)} to #{inspect(fix_seen)}")
      end
      Model.RoleLog.changeset(r, %{seen: fix_date_range(r.seen)})
    end)
  end

  def fix_person_roles do
    Repo.all(Model.Person)
    |> Enum.map(&Crawler.person/1)
  end
end
