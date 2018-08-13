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

  def save_role(%{person_info: p, role_info: r}) do
    person_id = Map.get(p, :person_id)
    if person_id do p |> Model.Query.update_person end
    Map.put(r, :person_id, person_id) |> Model.Query.update_role
  end
  def save_role(%{}) do :error end

  def top200(client \\ nil) do
    GenServer.call(client || lookup(), {:top200}) |> Enum.map(fn %{person_info: _p, role_info: r} = a ->
      save_role(a)
      role(r)
    end)
  end

  def role(client \\ nil, %{role_id: role_id, zone: zone, server: server}) do
    GenServer.call(client || lookup(), {:role_info, role_id, zone, server}) |> save_role
  end
end
