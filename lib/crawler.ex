defmodule Crawler do

  def start_link(%{username: _, password: _} = cred) do
    GenServer.start_link(Jx3APP, cred)
  end

  def top200(client) do
    GenServer.call(client, {:top200})
  end

  def role(client, %{role_id: role_id, zone: zone, server: server}) do
    GenServer.call(client, {:role_info, role_id, zone, server})
  end
end
