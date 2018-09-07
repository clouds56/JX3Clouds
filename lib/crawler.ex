defmodule Crawler do
  require Logger

  def start_link do
    {:ok, spawn_link(&run/0)}
  end

  def time_in?(t, d, u \\ :second) do
    d = d * case u do
      :second -> 1
      :minute -> 60
      :hour -> 3600
      :day -> 24 * 3600
      :week -> 7 * 24 * 3600
    end
    case t do
      nil -> false
      _ -> NaiveDateTime.diff(NaiveDateTime.utc_now, t) <= d
    end
  end

  def unwrap({:ok, result}), do: result
  def unwrap(_), do: nil
  def unstruct(%_{} = o), do: Map.from_struct(o)
  def unstruct(%{} = o), do: o
  def unstruct(_), do: %{}
  def filter_into(a, b \\ %{}) do
    a |> Enum.filter(fn {_, v} -> v != nil end) |> Enum.into(b |> unstruct)
  end

  def save_performance(_, nil), do: []
  def save_performance(%Model.Role{} = r, perf) do
    perf |> Enum.map(fn i ->
      pvp_type = i[:type]
      with %{} = i <- Map.get(i, :performance),
        i <- i |> Map.put(:pvp_type, pvp_type) |> Map.put(:role_id, Map.get(r,:global_id)),
        true <- i[:score] != nil,
        {:ok, i} <- i |> Model.Query.update_performance
      do
        i
      else
        _ -> nil
      end
    end) |> Enum.filter(&(&1!=nil))
  end

  def save_role(a, o \\ nil)
  def save_role(%{person_info: p, role_info: r} = a, o) do
    person_id = Map.get(p, :person_id)
    if person_id do p |> Model.Query.update_person end
    r = r |> filter_into(o)
    Map.put(r, :person_id, person_id) |> Model.Query.update_role |> unwrap
  end
  def save_role(nil, o) do
    o = unstruct(o)
    Map.put(o, :person_id, nil) |> Model.Query.update_role |> unwrap
  end

  def top200 do
    top = GenServer.call(Jx3APP, {:top200})
    if top do
      top |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
        save_role(a)
        role_seen(r, Date.utc_today)
      end)
    end
  end

  def role_seen(%{global_id: id} = r, seen) do
    r_now = Model.Query.get_role(id) || new_role(r)
    r |> filter_into(r_now) |> Map.put(:seen, seen) |> Model.Query.insert_role_log
  end

  def new_role(%{global_id: _} = r) do
    r = update_role(r)
    if Map.get(r, :person_id) do
      person(r)
    end
  end

  def update_role(r) do
    r = indicator(role(r))
  end

  def role(%{global_id: global_id} = r) do
    GenServer.call(Jx3APP, {:role_info, global_id}) |> save_role(r)
  end

  def indicator(%{role_id: role_id, zone: zone, server: server} = r) do
    GenServer.call(Jx3APP, {:role_info, role_id, zone, server}) |> save_role(r)
  end

  def person(%{person_id: person_id}) do
    if person_id != "" and person_id != nil do
      GenServer.call(Jx3APP, {:person_roles, person_id}) |> Enum.map(&save_role/1)
    end
  end

  def matches(%{global_id: global_id}, size \\ 100) do
    history = GenServer.call(Jx3APP, {:role_history, global_id, 0, size || 100})
    if history do
      history |> Enum.map(fn %{match_id: id} = m ->
        Model.Query.get_match(id) || match(m) || m
      end)
    end || []
  end

  def match(%{match_id: match_id} = m) do
    detail = GenServer.call(Jx3APP, {:match_detail, match_id})
    if detail do
      detail |> Map.get(:roles) |> Enum.map(fn r ->
        role_seen(r, DateTime.from_unix(detail[:start_time]) |> unwrap)
      end)
      avg_grade = case Map.get(detail, :grade, nil) do
        nil -> Map.get(m, :avg_grade, nil)
        0 -> Map.get(m, :avg_grade, nil)
        x -> x
      end
      detail = detail |> Map.put(:grade, avg_grade) |> Model.Query.insert_match |> unwrap
      replay = GenServer.call(Jx3APP, {:match_replay, match_id})
      if replay do replay |> Model.Query.insert_match_log end
      detail
    end || detail
  end

  def is_zone_telecom(role) do
    case role do
      %{zone: zone} when zone != nil -> String.starts_with?(zone, "\u7535\u4FE1")
      _ -> nil
    end
  end

  def do_fetch(role, pvp_type, perf, opts \\ []) do
    global_id = Map.get(role, :global_id)
    indicators = case role do
      %{role_id: role_id, zone: zone, server: server} -> GenServer.call(Jx3APP, {:role_info, role_id, zone, server})
      _ -> nil
    end
    performances = indicators[:indicator] || []
    {count, new_rank} =
      case performances |> Enum.filter(fn p -> Integer.parse(p[:type]) == {pvp_type, "c"} end) do
        [%{performance: new_perf}] ->
          count = case {new_perf[:total_count], Map.get(perf, :total_count)} do
            {nil, _} -> nil
            {_, nil} -> nil
            {x, y} -> x - y
          end
          ranking = new_perf[:ranking]
          {count, ranking}
        _ -> {nil, nil}
      end
    count = case count do
      nil -> nil
      x when x <=0 -> 3
      x when x < 50 -> x + 5
      x -> round(x*1.1)
    end
    limit = case {count, opts[:limit]} do
      {nil, limit} -> limit
      {x, nil} -> x
      {x, y} -> min(x, y)
    end
    Logger.info("fetching #{limit} matches of #{global_id} of #{Map.get(perf, :ranking)} -> #{new_rank}")
    history = if is_zone_telecom(role) != false do
      if limit == nil do
        Logger.error("limit should not be null #{performances |> Enum.map(& &1[:type]) |> inspect}\n" <> inspect(indicators))
      end
      matches(role, limit)
    else
      Logger.warn("#{global_id} not in zone of Telecom, skip")
      nil
    end || []
    save_role(indicators, role)
    new_perf = %{role_id: global_id, pvp_type: pvp_type, fetch_at: NaiveDateTime.utc_now}
    new_perf =
      case history |> Enum.drop_while(fn %Model.Match{} -> false; _ -> true end) do
        [%Model.Match{} = h | _] ->
          roles = Model.Repo.preload(h, :roles).roles
          case roles |> Enum.filter(&(&1 != nil and &1.role_id == role.global_id)) do
            [r] -> new_perf |> Map.put(:score2, r.score2)
            _ ->
              Logger.error("Error when fetching #{global_id}: " <> inspect(roles))
              new_perf
          end
        _ ->
          Logger.info("No match fetched for #{global_id}")
          new_perf
      end
    new_perf |> Model.Query.update_performance |> unwrap
  end

  def fetch(role, %{pvp_type: pvp_type, ranking: ranking, fetch_at: last} = perf) do
    cond do
      ranking >= -3 and last == nil -> do_fetch(role, pvp_type, %{ranking: ranking}, limit: 100)
      last == nil -> do_fetch(role, pvp_type, %{ranking: ranking}, limit: 20)
      ranking in [-1, -2, -3] and not time_in?(last, 6, :day) -> do_fetch(role, pvp_type, perf, limit: 100)
      ranking > 0 and not time_in?(last, 18, :hour) -> do_fetch(role, pvp_type, perf)
      not time_in?(last, 7, :day) -> do_fetch(role, pvp_type, perf, limit: 10)
      true -> nil
    end
  end

  def run do
    Model.Query.get_roles |> Enum.map(fn {r, p} ->
      try do
        Crawler.fetch(r, p)
      catch
        :exit, e when e != :stop -> Logger.error "Crawler (exit): " <> Exception.format(:error, e, __STACKTRACE__)
          :error
      end
    end)
    Logger.info("Done")
  end

  def start do
    spawn(&run/0)
  end

  def stop(pid) do
    Process.exit(pid, :stop)
  end
end
