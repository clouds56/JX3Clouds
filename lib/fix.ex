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
    roles |> Enum.each(fn r ->
      size = Model.Query.get_matches_by_role("3c", r) |> Enum.count
      size = trunc(size * 1.1)
      Logger.info("fetching matches of #{r} of size #{size}")
      history = Crawler.api({:role_history, r, 0, size})
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
    |> Enum.map(fn p ->
      Logger.info("renew person #{p.person_id} #{p.name}")
      try do
        Crawler.person(p)
      catch
        :exit, e when e != :stop -> Logger.error "Fix (exit): " <> Exception.format(:error, e, __STACKTRACE__)
          :error
      end
    end)
  end

  def get_score_from_match(role_id) do
    Logger.debug("get #{role_id} performance from matches")
    case Crawler.api({:role_history, "3c", role_id, 0, 1}) do
      [%{match_id: match_id, match_type: match_type} = m | _] ->
        detail = Crawler.api({:match_detail, match_type, match_id})
        if detail do
          result = detail |> Map.get(:roles) |> Enum.filter(fn r -> r[:global_id] == role_id end)
          |> Enum.map(fn perf ->
            perf |> Map.put(:role_id, role_id) |> Map.put(:match_type, match_type) |> Model.Query.update_performance
          end)
          Crawler.save_match(detail, m)
          result
        end
      _ -> nil
    end
  end

  def fix_role_scores(offset \\ 0, limit \\ 100, index \\ 0) do
    Logger.info("fix_role_scores #{index}: #{offset} +#{limit}")
    roles = Repo.all(from(r in Model.Role,
      left_join: s in Model.RolePerformance,
      on: r.global_id == s.role_id,
      inner_join: m in ^Model.MatchRole.subquery("3c"),
      on: r.global_id == m.role_id,
      where: is_nil(s.role_id),
      group_by: r.global_id,
      order_by: r.global_id,
      offset: ^offset,
      limit: ^limit))
    failed = roles |> Enum.map(fn r ->
      Logger.debug("update role #{r.global_id} #{r.zone} #{r.name}")
      r1 = Crawler.update_role(r) |> Model.Repo.preload([:performances])
      if r1.performances == [] do
        case get_score_from_match(r.global_id) do
          [_ | _] -> 0
          e -> Logger.error("update role 3#{API.get_zone_suffix(r.zone)} #{r.global_id} failed\n" <> inspect(e)); 1
        end
      else
        0
      end
    end) |> Enum.sum
    if length(roles) >= limit do
      fix_role_scores(offset + failed, limit, index + 1)
    end
  end
end
