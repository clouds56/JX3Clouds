defmodule Jx3App.Crawler do
  require Logger
  alias Jx3App.{Model, API, Utils}

  def start_link do
    {:ok, spawn_link(&run/0)}
  end

  def save_performance(_, nil), do: []
  def save_performance(%Model.Role{} = r, perf) do
    perf |> Enum.map(fn i ->
      match_type = i[:match_type]
      with %{} = i <- Map.get(i, :performance),
        i <- i |> Map.put(:match_type, match_type) |> Map.put(:role_id, Map.get(r,:global_id)),
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
  def save_role(%{person_info: p, role_info: r}, o) do
    person_id = Map.get(p, :person_id)
    if person_id do p |> Model.Query.update_person end
    r = r |> Utils.filter_into(o)
    Map.put(r, :person_id, person_id) |> Model.Query.update_role |> Utils.unwrap
  end
  def save_role(nil, o) do
    o = Utils.unstruct(o)
    Map.put(o, :person_id, nil) |> Model.Query.update_role |> Utils.unwrap
  end

  def save_match(nil, _), do: nil
  def save_match(detail, m) do
    detail |> Map.get(:roles) |> Enum.map(fn r ->
      role_seen(r, DateTime.from_unix(detail[:start_time]) |> Utils.unwrap)
    end)
    avg_grade = case Map.get(detail, :grade, nil) do
      nil -> Map.get(m, :avg_grade, nil)
      0 -> Map.get(m, :avg_grade, nil)
      x -> x
    end
    (detail |> Map.put(:grade, avg_grade) |> Model.Query.insert_match |> Utils.unwrap) || detail
  end

  def api(req) do
    GenServer.call(API, req)
  end

  def top200(match_type \\ "3c") do
    top = api({:top200, match_type})
    if top do
      top |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
        save_role(a) |> new_role
        role_seen(r, Date.utc_today)
      end)
    end
  end

  def role_seen(%Model.Role{} = r, seen) do
    r |> Utils.unstruct |> Map.put(:seen, seen) |> Model.Query.insert_role_log
    r
  end
  def role_seen(%{global_id: id} = r, seen) do
    r_now = Model.Query.get_role(id) || new_role(r)
    r |> Utils.filter_into(r_now) |> Map.put(:seen, seen) |> Model.Query.insert_role_log
    r_now
  end

  def new_role(%{global_id: _} = r) do
    r = update_role(r)
    if Map.get(r, :person_id) do
      person(r)
    end
    r
  end

  def update_role(r) do
    result = indicator(role(r))
    result |> Utils.unstruct |> Map.put(:seen, Date.utc_today) |> Model.Query.insert_role_log
    result
  end

  def check_role(%Model.Role{} = r) do
    case Model.Repo.preload(r, [:performances]).performances do
      nil -> update_role(r)
      [] -> update_role(r)
      _ -> r
    end
  end
  def check_role(%{global_id: id} = r) do
    case Model.Query.get_role(id) do
      nil -> update_role(r)
      r -> check_role(r)
    end
  end

  def role(match_type \\ nil, %{global_id: global_id} = r) do
    match_type = case {match_type, Map.get(r, :zone)} do
      {nil, nil} -> "3c"
      {nil, z} -> case Utils.get_zone_suffix(z) do
        "" -> "3c"
        s -> "3" <> s
      end
      {x, _} -> x
    end
    api({:role_info, match_type, global_id}) |> save_role(r)
  end

  def indicator(%{role_id: role_id, zone: zone, server: server} = r) do
    r1 = api({:role_info, role_id, zone, server})
    result = save_role(r1, r)
    Map.put(result, :performances, save_performance(result, r1[:indicator]))
  end

  def person(%{person_id: person_id}) do
    if person_id != "" and person_id != nil do
      api({:person_roles, person_id}) |> Enum.map(fn r ->
        case r[:role_info][:level] do
          "95" -> save_role(r) |> check_role
          95 -> save_role(r) |> check_role
          _ -> r[:role_info]
        end |> Utils.unstruct |> Map.put(:seen, Date.utc_today) |> Model.Query.insert_role_log
      end)
    end
  end

  def matches(match_type \\ "3c", %{global_id: global_id}, size \\ 100) do
    history = api({:role_history, match_type, global_id, 0, size || 100})
    if history do
      history |> Enum.map(fn %{match_id: id, match_type: match_type} = m ->
        Model.Query.get_match(match_type, id) || match(m) || m
      end)
    end || []
  end

  def match(%{match_id: match_id, match_type: match_type} = m) do
    detail = api({:match_detail, match_type, match_id}) |> save_match(m)
    replay = api({:match_replay, match_type, match_id})
    if replay do replay |> Model.Query.insert_match_log end
    detail
  end

  def do_fetch(role, match_type, perf, opts \\ []) do
    global_id = Map.get(role, :global_id)
    indicators = case role do
      %{role_id: role_id, zone: zone, server: server} -> api({:role_info, role_id, zone, server})
      _ -> nil
    end
    performances = indicators[:indicator] || []
    {count, new_rank} =
      case performances |> Enum.filter(fn p -> p[:match_type] == match_type end) do
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
    if limit == nil do
      Logger.error("limit should not be null #{performances |> Enum.map(& &1[:type]) |> inspect}\n" <> inspect(indicators))
    end
    history = matches(match_type, role, limit) || []
    save_role(indicators, role)
    save_performance(role, indicators[:indicator])
    new_perf = %{role_id: global_id, match_type: match_type, fetch_at: NaiveDateTime.utc_now}
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
    new_perf |> Model.Query.update_performance |> Utils.unwrap
  end

  def fetch(role, %{match_type: match_type, ranking: ranking, fetch_at: last} = perf) do
    cond do
      ranking >= -3 and last == nil -> do_fetch(role, match_type, %{ranking: ranking}, limit: 100)
      last == nil -> do_fetch(role, match_type, %{ranking: ranking}, limit: 20)
      ranking in [-1, -2, -3] and not Utils.time_in?(last, 6, :day) -> do_fetch(role, match_type, perf, limit: 100)
      ranking > 0 and not Utils.time_in?(last, 18, :hour) -> do_fetch(role, match_type, perf)
      not Utils.time_in?(last, 7, :day) -> do_fetch(role, match_type, perf, limit: 10)
      true -> nil
    end
  end

  def run do
    Model.Query.get_roles(:all) |> Enum.map(fn {r, p} ->
      try do
        fetch(r, p)
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
