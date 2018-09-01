defmodule Crawler do
  require Logger

  def start_link do
    run()
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
      _ -> NaiveDateTime.diff(NaiveDateTime.utc_now, t) >= d
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
    Map.put(r, :person_id, person_id) |> Model.Query.update_role
    Map.get(a, :indicator, []) |> Enum.map(fn i ->
      i = i |> Map.get(:performance) |> Map.put(:pvp_type, Map.get(i, :type)) |> Map.put(:role_id, Map.get(r, :global_id))
      if i |> Map.get(:score, nil) do
        i |> Model.Query.update_performance
      end
    end)
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
      Logger.info("fetching matches of #{global_id}")
      history |> Enum.map(fn %{match_id: id} = m ->
        Model.Query.get_match(id) || match(client, m)
      end)
    end || history
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
      avg_grade = Map.get(detail, :grade, nil) || Map.get(m, :avg_grade, nil)
      {:ok, detail} = detail |> Map.put(:grade, avg_grade) |> Model.Query.insert_match
      replay = GenServer.call(client, {:match_replay, match_id})
      if replay do replay |> Model.Query.insert_match_log end
      detail
    end || detail
  end

  def fetch(client \\ nil, role, %{ranking: ranking, fetch_at: last}) do
    client = client || Jx3APP.lookup()
    history = cond do
      ranking in [-1, -2, -3] and time_in?(last, 6, :day) -> matches(client, role)
      ranking > 0 and time_in?(last, 18, :hour) -> matches(client, role)
      time_in?(last, 7, :day) -> matches(client, role, 10)
      true -> []
    end
    with [%Model.Match{} = h | _] <- history,
         [r | _] <-
            h |> Model.Repo.preload(:roles) |> Map.get(:roles) |> Enum.filter(fn r -> r.role_id == role.global_id end),
         pvp_type <- h.pvp_type
    do
      %{role_id: role.global_id, pvp_type: pvp_type, score2: r.score2, fetch_at: NaiveDateTime.utc_now}
      |> Model.Query.update_performance
    else
      err -> if history != [] do Logger.error "Error when fetching #{role.global_id}: " <> inspect(err) end
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

  def fix_match_array_order do
    Model.Query.get_matches |> Enum.each(fn m ->
      {:ok, _} = Model.Match.changeset(m, %{team1: Enum.sort(m.team1), team2: Enum.sort(m.team2)})
      |> Model.Repo.update
    end)
    :ok
  end
end
