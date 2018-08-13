defmodule Jx3APP do
  @moduledoc """
  Documentation for Crawler.
  """

  use GenServer

  def pad_int(d, i) do
    d
    |> Integer.to_string
    |> String.pad_leading(i, "0")
  end

  @doc """
  sign data
  """
  def timestamp do
    %DateTime{year: y, month: m, day: d, hour: hh, minute: mm, second: ss, microsecond: {ms, _}} = DateTime.utc_now
    "#{pad_int(y, 4)}#{pad_int(m, 2)}#{pad_int(d, 2)}#{pad_int(hh, 2)}#{pad_int(mm, 2)}#{pad_int(ss, 2)}#{pad_int(ms, 6) |> String.slice(0..2)}"
  end

  def secret_key do
    "xv3r8cy1v1abdmi6"
  end

  @doc """
  sign data
  """
  def sign_data(d) do
    d = case d do
      %{ts: _} -> d
      %{} -> Map.put(d, :ts, timestamp())
    end
    s = d |> Enum.sort
    |> Enum.map(fn({a, b}) -> "#{a}=#{b}" end)
    |> Enum.join("&")
    s = :crypto.hmac(:sha, secret_key(), s) |> Base.encode16(case: :lower)
    Map.put(d, :sign, s)
  end

  def _post(url, body, option) do
    body = sign_data body
    option = Keyword.put_new(option, :"Content-Type", "application/json")
    case Poison.encode body do
      {:error, _} -> {:error, :encode}
      {:ok, body} ->
        case HTTPoison.post(url, body, option) do
          {:error, _} -> {:error, :post}
          {:ok, %HTTPoison.Response{body: body}} -> 
            case Poison.decode body do
              {:error, _} -> {:error, :decode}
              {:ok, o} -> {:ok, o}
            end
        end
    end
  end

  def post(url, body, token) do
    _post(url, body, [{:token, token}])
  end

  def post(url, body) do
    _post(url, body, [])
  end

  def login(username, password, device \\ "CURL") do
    {_, d} = _post(
      "https://m.pvp.xoyo.com/user/login",
      %{
        passportId: username,
        password: :crypto.hash(:md5, password) |> Base.encode64,
      },
      [{:deviceid, device}]
    )
    d |> Map.get("data", %{}) |> Map.get("token", "")
  end

  @impl true
  def init(%{username: u, password: p, deviceid: id}) do
    {:ok, %{token: login(u, p, id)}}
  end

  @impl true
  def init(%{username: _, password: _} = cred) do
    init(Map.put(cred, :deviceid, "CURL"))
  end

  @impl true
  def handle_call({:top200}, _from, state) do
    {_, d} = post("https://m.pvp.xoyo.com/3c/mine/arena/top200", %{})
    r = d |> Map.get("data", []) |> Enum.map(fn p ->
      r = Map.get(p, "personInfo")
      %{
        role_info: %{
          global_id: Map.get(p, "globalId"), # assert == Map.get(r, gameGlobalRoleId)
          role_id: Map.get(r, "gameRoleId") |> String.to_integer,
          name: Map.get(r, "roleName"),
          server: Map.get(r, "server"),
          zone: Map.get(r, "zone"),
          force: Map.get(r, "force"),
          body_type: Map.get(r, "bodyType"),
          camp: nil,
        },
        person_info: %{
          passport_id: Map.get(p, "passportId"),
          person_id: Map.get(p, "personId"),
          name: Map.get(r, "person") |> Map.get("nickName"),
          avatar: Map.get(r, "person") |> Map.get("avatarUrl"),
          signature: Map.get(r, "person") |> Map.get("signature"),
        }
      }
    end)
    {:reply, r, state}
  end

  @impl true
  def handle_call({:person_info, person_id}, _from, %{token: token} = state) do
    {:reply, post("https://m.pvp.xoyo.com/socialgw/summary", %{personId: person_id}, token), state}
  end

  @impl true
  def handle_call({:person_history, person_id, cursor, size}, _from, %{token: token} = state) do
    {:reply, post("https://m.pvp.xoyo.com/mine/match/person-history", %{personId: person_id, cursor: cursor, size: size}, token), state}
  end

  @impl true
  def handle_call({:role_info, role_id, zone, server}, _from, state) do
    {:ok, d} = post("https://m.pvp.xoyo.com/role/indicator", %{role_id: "#{role_id}", zone: zone, server: server})
    p = Map.get(d, "data") |> Map.get("person_info")
    r = Map.get(d, "data") |> Map.get("role_info")
    t = Map.get(d, "data") |> Map.get("indicator")
    d = %{
      role_info: %{
        global_id: Map.get(r, "global_role_id"),
        role_id: Map.get(r, "role_id") |> String.to_integer,
        name: Map.get(r, "name"),
        server: Map.get(r, "server"),
        zone: Map.get(r, "zone"),
        force: Map.get(r, "force"),
        body_type: Map.get(r, "body_type"),
        camp: Map.get(r, "camp"),
      },
      person_info: %{
        passport_id: nil,
        person_id: Map.get(p, "person_id"),
        name: Map.get(p, "person_name"),
        avatar: Map.get(r, "person_avatar"),
        signature: nil,
      },
      indicator: t |> Enum.map(fn i ->
        %{
          #match_type: Map.get(i, "match_type"),
          type: Map.get(i, "type"),
          metrics: (Map.get(i, "metrics") || []) |> Enum.map(fn t ->
            {Map.get(t, "kungfu"), %{
              kungfu: Map.get(t, "kungfu"),
              mvp_count: Map.get(t, "mvp_count"),
              pvp_type: Map.get(t, "pvp_type"),
              total_count: Map.get(t, "total_count"),
              win_count: Map.get(t, "win_count"),
              items: Map.get(t, "items") |> Enum.map(fn i ->
                {Map.get(i, "name"), %{
                  grade: Map.get(i, "grade"),
                  name: Map.get(i, "name"),
                  value: Map.get(i, "value"),
                  ranking: Map.get(i, "ranking"),
                }}
              end),
            }}
          end),
          performance: Map.get(i, "performance") || %{},
        }
      end)
    }
    {:reply, d, state}
  end

  @impl true
  def handle_call({:role_history, global_role_id, cursor, size}, _from, %{token: token} = state) do
    {:reply, post("https://m.pvp.xoyo.com/3c/mine/match/history", %{global_role_id: global_role_id, cursor: cursor, size: size}, token), state}
  end

  @impl true
  def handle_call({:match_replay, match_id}, _from, %{token: token} = state) do
    {:reply, post("https://m.pvp.xoyo.com/3c/mine/match/replay", %{match_id: match_id}, token), state}
  end

  @impl true
  def handle_call({:match_detail, match_id}, _from, %{token: token} = state) do
    {:reply, post("https://m.pvp.xoyo.com/3c/mine/match/detail", %{match_id: match_id}, token), state}
  end
end
