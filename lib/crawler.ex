defmodule Crawler do
  require Logger

  def start_link do
    start_link(Application.get_env(:jx3replay, Crawler) |> Enum.into(%{}))
  end

  def start_link(%{username: _, password: _} = cred) do
    GenServer.start_link(Jx3APP, cred, [name: Jx3APP])
  end

  def lookup do
    GenServer.whereis(Jx3APP)
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

  def foreach_role(fun) do
    Model.Query.get_roles |> Enum.map(fun)
  end

  def top200(client \\ nil) do
    client = client || lookup()
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
    GenServer.call(client || lookup(), {:role_info, global_id}) |> save_role(r)
  end

  def indicator(client \\ nil, %{role_id: role_id, zone: zone, server: server} = r) do
    GenServer.call(client || lookup(), {:role_info, role_id, zone, server}) |> save_role(r)
  end

  def matches(client \\ nil, %{global_id: global_id}) do
    client = client || lookup()
    history = GenServer.call(client, {:role_history, global_id})
    if history do
      Logger.debug("fetching matches of #{global_id}")
      history |> Enum.map(fn %{match_id: id} = m ->
        if !Model.Query.get_match(id) do
          match(client, m)
        end
      end)
    end
  end

  def match(client \\ nil, %{match_id: match_id}) do
    client = client || lookup()
    detail = GenServer.call(client, {:match_detail, match_id})
    if detail do
      detail |> Map.get(:roles) |> Enum.map(fn %{global_id: id} = r ->
        if !Model.Query.get_role(id) do
          role(client, r)
          indicator(client, r)
        end
      end)
      detail |> Model.Query.insert_match
      replay = GenServer.call(client, {:match_replay, match_id})
      if replay do replay |> Model.Query.insert_match_log end
    end
  end

  def start do
    # spawn(fn -> Crawler.foreach_role(&Crawler.matches(Crawler.lookup, &1)) end)
    spawn(fn -> Crawler.foreach_role(&Crawler.indicator(Crawler.lookup, &1)) end)
  end
end
