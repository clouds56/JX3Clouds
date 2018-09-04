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
      nil -> true
      _ -> NaiveDateTime.diff(NaiveDateTime.utc_now, t) <= d
    end
  end

  def save_role(a, o \\ nil)
  def save_role(%{person_info: p, role_info: r} = a, o) do
    person_id = Map.get(p, :person_id)
    if person_id do p |> Model.Query.update_person end
    o = case o do
      %_{} -> Map.from_struct(o)
      %{} -> o
    end
    r = r |> Enum.filter(fn {_, v} -> v != nil end) |> Enum.into(o || %{})
    result = with {:ok, result} <- Map.put(r, :person_id, person_id) |> Model.Query.update_role
      do result else _ -> nil end
    performances = Map.get(a, :indicator, []) |> Enum.map(fn i ->
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
    if result != nil and performances != [] do
      Map.put(result, :performances, performances)
    else
      result
    end
  end
  def save_role(nil, o) do
    o = case o do
      %_{} -> Map.from_struct(o)
      %{} -> o
    end
    Map.put(o, :person_id, nil) |> Model.Query.update_role
  end

  def top200(client \\ nil) do
    client = client || Jx3APP.lookup()
    top = GenServer.call(client, {:top200})
    if top do
      top |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
        save_role(a)
        role(client, r)
        indicator(client, r)
      end)
    end
  end

  def role(client \\ nil, %{global_id: global_id} = r) do
    GenServer.call(client || Jx3APP.lookup(), {:role_info, global_id}) |> save_role(r)
  end

  def indicator(client \\ nil, %{role_id: role_id, zone: zone, server: server} = r) do
    GenServer.call(client || Jx3APP.lookup(), {:role_info, role_id, zone, server}) |> save_role(r)
  end

  def matches(client \\ nil, %{global_id: global_id}, size \\ 100) do
    client = client || Jx3APP.lookup()
    history = GenServer.call(client, {:role_history, global_id, 0, size})
    if history do
      history |> Enum.map(fn %{match_id: id} = m ->
        Model.Query.get_match(id) || match(client, m) || m
      end)
    end || []
  end

  def match(client \\ nil, %{match_id: match_id} = m) do
    client = client || Jx3APP.lookup()
    detail = GenServer.call(client, {:match_detail, match_id})
    if detail do
      detail |> Map.get(:roles) |> Enum.map(fn %{global_id: id} = r ->
        if !Model.Query.get_role(id) do
          role(client, r)
          indicator(client, r)
        end
      end)
      avg_grade = case Map.get(detail, :grade, nil) do
        nil -> Map.get(m, :avg_grade, nil)
        0 -> Map.get(m, :avg_grade, nil)
        x -> x
      end
      {:ok, detail} = detail |> Map.put(:grade, avg_grade) |> Model.Query.insert_match
      replay = GenServer.call(client, {:match_replay, match_id})
      if replay do replay |> Model.Query.insert_match_log end
      detail
    end || detail
  end

  def do_fetch(client \\ nil, role, perf, opts \\ []) do
    client = client || Jx3APP.lookup()
    performances = Map.get(indicator(client, role), :performances) || []
    {count, new_rank} = with true <- Map.get(perf, :pvp_type) != nil and is_number(Map.get(perf, :total_count)),
      [new_perf] <- performances |> Enum.filter(fn p -> Map.get(p, :pvp_type) == Map.get(perf, :pvp_type) end),
      true <- is_number(Map.get(new_perf, :total_count))
    do
      count = Map.get(new_perf, :total_count) - Map.get(perf, :total_count)
      ranking = Map.get(new_perf, :ranking)
      {count, ranking}
    else
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
    Logger.info("fetching #{limit} matches of #{Map.get(role, :global_id)} of #{Map.get(perf, :ranking)} -> #{new_rank}")
    matches(client, role, limit)
  end

  def fetch(client \\ nil, role, %{ranking: ranking, fetch_at: last} = perf) do
    client = client || Jx3APP.lookup()
    history = cond do
      ranking in [-1, -2, -3] and not time_in?(last, 6, :day) -> do_fetch(client, role, perf, limit: 100)
      ranking > 0 and not time_in?(last, 18, :hour) -> do_fetch(client, role, perf)
      not time_in?(last, 7, :day) -> do_fetch(client, role, perf, limit: 10)
      true -> nil
    end
    with [%Model.Match{} = h | _] <-
            (history || []) |> Enum.drop_while(fn m -> case m do %Model.Match{} -> false; _ -> true end end),
         [:role, r] <-
            [:role] ++ (h |> Model.Repo.preload(:roles) |> Map.get(:roles) |> Enum.filter(fn r -> r != nil and r.role_id == role.global_id end))
    do
      %{role_id: role.global_id, pvp_type: h.pvp_type, score2: r.score2, fetch_at: NaiveDateTime.utc_now}
      |> Model.Query.update_performance
    else
      err -> if history != nil do
        hs = Enum.drop_while(history || [], fn m -> case m do %Model.Match{} -> false; _ -> true end end) |> Enum.take(1)
        Logger.error("Error when fetching #{role.global_id}: " <> inspect(err) <> "\n" <> inspect(hs) <> "\n" <>
        case {err, hs} do
          {[:role], [h | _]} ->
            h |> Model.Repo.preload(:roles) |> Map.get(:roles) |> inspect
          _ -> ""
        end)
        with [h | _] <- history,
          pvp_type <- Map.get(h, :pvp_type),
          true <- pvp_type != nil
        do
          %{role_id: role.global_id, pvp_type: pvp_type, fetch_at: NaiveDateTime.utc_now}
          |> Model.Query.update_performance
        else
          _ -> nil
        end
      end
    end
  end

  def run do
    Model.Query.get_roles |> Enum.map(fn {r, p} ->
      try do
        Crawler.fetch(Jx3APP.lookup, r, p)
      catch
        :exit, e when e != :stop -> Logger.error "Crawler (exit): " <> Exception.format(:error, e, __STACKTRACE__)
          :error
      end
    end)
  end

  def start do
    spawn(&run/0)
  end

  def stop(pid) do
    Process.exit(pid, :stop)
  end
end
