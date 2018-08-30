defmodule Crawler do

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
      pvp_type = case Map.get(i, :type) do
        x when x in ["2c", "2d"] -> 2
        x when x in ["3c", "3d"] -> 3
        x when x in ["5c", "5d"] -> 5
        _ -> 0
      end
      i = i |> Map.get(:performance) |> Map.put(:pvp_type, pvp_type) |> Map.put(:role_id, Map.get(r, :global_id))
      if i |> Map.get(:score, nil) do
        i |> Model.Query.insert_performance
      end
    end)
  end
  def save_role(nil, o) do
    o = case o do
      %{} -> o
      %_{} -> Map.from_struct(o)
    end
    Map.put(o, :person_id, nil) |> Model.Query.update_role
  end

  def foreach_role(fun) do
    Model.Query.get_roles |> Enum.map(fun)
  end

  def top200(client \\ nil) do
    client = client || lookup()
    GenServer.call(client, {:top200}) |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
      save_role(a)
      role(client, r)
      indicator(client, r)
    end)
  end

  def role(client \\ nil, %{global_id: global_id} = r) do
    GenServer.call(client || lookup(), {:role_info, global_id}) |> save_role(r)
  end

  def indicator(client \\ nil, %{role_id: role_id, zone: zone, server: server} = r) do
    GenServer.call(client || lookup(), {:role_info, role_id, zone, server}) |> save_role(r)
  end

  def matches(client \\ nil, %{global_id: global_id}) do
    client = client || lookup()
    GenServer.call(client, {:role_history, global_id}) |> Enum.map(fn %{match_id: id} = m ->
      if !Model.Query.get_match(id) do
        match(client, m)
      end
    end)
  end

  def match(client \\ nil, %{match_id: match_id}) do
    client = client || lookup()
    detail = GenServer.call(client, {:match_detail, match_id})
    detail |> Map.get(:roles) |> Enum.map(fn %{global_id: id} = r ->
      if !Model.Query.get_role(id) do
        role(client, r)
        indicator(client, r)
      end
    end)
    detail |> Model.Query.insert_match
    GenServer.call(client, {:match_replay, match_id}) |> Model.Query.insert_match_log
  end
end
