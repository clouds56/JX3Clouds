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

  def save_role(%{person_info: p, role_info: r} = a) do
    person_id = Map.get(p, :person_id)
    if person_id do p |> Model.Query.update_person end
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
  def save_role(%{}) do :error end

  def top200(client \\ nil) do
    client = client || lookup()
    GenServer.call(client, {:top200}) |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
      save_role(a)
      role(client, r)
    end)
  end

  def role(client \\ nil, %{role_id: role_id, zone: zone, server: server}) do
    GenServer.call(client || lookup(), {:role_info, role_id, zone, server}) |> save_role
  end

  def matches(client \\ nil, %{global_id: global_id}) do
    client = client || lookup()
    GenServer.call(client, {:role_history, global_id}) |> Enum.map(fn %{match_id: match_id} ->
      match(client, match_id)
    end)
  end

  def match(client \\ nil, %{match_id: match_id}) do
    client = client || lookup()
    detail = GenServer.call(client, {:match_detail, match_id})
    detail |> Map.get(:roles) |> Enum.map(fn %{global_id: id} = r ->
      if !Model.Query.get_role(id) do
        role(client, r)
      end
    end)
    detail |> Model.Query.insert_match
    GenServer.call(client || lookup(), {:match_replay, match_id}) |> Model.Query.insert_match_log
  end
end
