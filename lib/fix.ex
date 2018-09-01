defmodule Model.Fix do
  import Ecto.Query
  require Logger
  alias Model.Repo

  def fix_match_array_order do
    Model.Query.get_matches |> Enum.each(fn m ->
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
      size = Model.Query.get_matches_by_role(r) |> Enum.count
      size = trunc(size * 1.1)
      Logger.info("fetching matches of #{r} of size #{size}")
      history = GenServer.call(client, {:role_history, r, 0, size})
      if size != Enum.count(history) do
        Logger.error("size != history.count (#{size} != #{Enum.count(history)}) [with global_id = #{r}]")
      end
      if history do
        history |> Enum.map(fn %{match_id: id} = m ->
          case Model.Query.get_match(id) do
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
end