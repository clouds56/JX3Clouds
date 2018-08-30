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

  def empty_nil(s) do
    case s do
      "" -> nil
      s -> s
    end
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
              {:ok, o} -> case o do
                %{"code" => 0, "data" => data} -> {:ok, data}
                %{"msg" => msg} -> {:error, msg}
              end
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
    {:ok, d} = _post(
      "https://m.pvp.xoyo.com/user/login",
      %{
        passportId: username,
        password: :crypto.hash(:md5, password) |> Base.encode64,
      },
      [{:deviceid, device}]
    )
    d |> Map.get("token", "")
  end

  @impl true
  def init(%{username: u, password: p, deviceid: id, sleep: sleep}) do
    {:ok, %{token: login(u, p, id), last: DateTime.utc_now, sleep: sleep}}
  end

  @impl true
  def init(%{username: _, password: _, deviceid: _} = cred) do
    init(Map.put(cred, :sleep, 500))
  end

  @impl true
  def init(%{username: _, password: _} = cred) do
    init(Map.put(cred, :deviceid, "CURL"))
  end

  @impl true
  def handle_call(req, _from, %{token: token, last: last, sleep: sleep} = state) do
    :timer.sleep(max(0, sleep - DateTime.diff(DateTime.utc_now, last, :millisecond)))
    {:reply, handle(elem(req, 0), Tuple.delete_at(req, 0), token), %{state | last: DateTime.utc_now}}
  end

  def handle(:top200, {}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/arena/top200", %{})
    d |> Enum.map(fn p ->
      r = Map.get(p, "personInfo")
      %{
        role_info: %{
          passport_id: Map.get(p, "passportId") |> empty_nil,
          global_id: Map.get(p, "globalId"), # assert == Map.get(r, gameGlobalRoleId)
          role_id: Map.get(r, "gameRoleId") |> String.to_integer,
          name: Map.get(r, "roleName") |> empty_nil,
          server: Map.get(r, "server") |> empty_nil,
          zone: Map.get(r, "zone") |> empty_nil,
          force: Map.get(r, "force") |> empty_nil,
          body_type: Map.get(r, "bodyType") |> empty_nil,
          camp: nil,
        },
        person_info: %{
          person_id: Map.get(p, "personId") |> empty_nil,
          name: Map.get(r, "person") |> Map.get("nickName") |> empty_nil,
          avatar: Map.get(r, "person") |> Map.get("avatarUrl") |> empty_nil,
          signature: Map.get(r, "person") |> Map.get("signature") |> empty_nil,
        }
      }
    end)
  end

  def handle(:person_info, {person_id}, token) do
    post("https://m.pvp.xoyo.com/socialgw/summary", %{personId: person_id}, token)
  end

  def handle(:person_history, {person_id, cursor, size}, token) do
    post("https://m.pvp.xoyo.com/mine/match/person-history", %{personId: person_id, cursor: cursor, size: size}, token)
  end

  def handle(:role_info, {global_id}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/arena/find-role-gid", %{globalId: global_id})
    p = d |> Map.get("personInfo")
    %{
      role_info: %{
        global_id: Map.get(p, "gameGlobalRoleId") |> empty_nil,
        role_id: case Map.get(p, "gameRoleId") do
          "" -> nil
          i -> i |> String.to_integer
        end,
        passport_id: Map.get(d, "passportId") |> empty_nil,
        name: Map.get(p, "roleName") |> empty_nil,
        server: Map.get(p, "server") |> empty_nil,
        zone: Map.get(p, "zone") |> empty_nil,
        force: Map.get(p, "force") |> empty_nil,
        body_type: Map.get(p, "bodyType") |> empty_nil, # nil
        camp: nil,
      },
      person_info: %{
        person_id: Map.get(d, "personId") |> empty_nil,
        name: Map.get(p, "person") |> Map.get("nickName") |> empty_nil,
        avatar: Map.get(p, "person") |> Map.get("avatarUrl") |> empty_nil,
        signature: nil,
      },
    }
  end

  def handle(:role_info, {role_id, zone, server}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/role/indicator", %{role_id: "#{role_id}", zone: zone, server: server})
    p = d |> Map.get("person_info")
    r = d |> Map.get("role_info")
    t = d |> Map.get("indicator")
    if r == nil do nil
    else
      %{
        role_info: %{
          passport_id: nil,
          global_id: Map.get(r, "global_role_id"),
          role_id: Map.get(r, "role_id") |> String.to_integer,
          name: Map.get(r, "name") |> empty_nil,
          server: Map.get(r, "server") |> empty_nil,
          zone: Map.get(r, "zone") |> empty_nil,
          force: Map.get(r, "force") |> empty_nil,
          body_type: Map.get(r, "body_type") |> empty_nil,
          camp: Map.get(r, "camp") |> empty_nil,
        },
        person_info: %{
          person_id: Map.get(p, "person_id") |> empty_nil,
          name: Map.get(p, "person_name") |> empty_nil,
          avatar: Map.get(r, "person_avatar") |> empty_nil,
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
                items: (Map.get(t, "items") || []) |> Enum.map(fn i ->
                  {Map.get(i, "name"), %{
                    grade: Map.get(i, "grade"),
                    name: Map.get(i, "name"),
                    value: Map.get(i, "value"),
                    ranking: Map.get(i, "ranking"),
                  }}
                end),
              }}
            end),
            performance: Map.get(i, "performance") && %{
              grade: Map.get(i, "performance") |> Map.get("grade"),
              score: Map.get(i, "performance") |> Map.get("mmr"),
              ranking: Map.get(i, "performance") |> Map.get("ranking"),
              total_count: Map.get(i, "performance") |> Map.get("total_count"),
              win_count: Map.get(i, "performance") |> Map.get("win_count"),
              mvp_count: Map.get(i, "performance") |> Map.get("mvp_count"),
            } || %{},
          }
        end)
      }
    end
  end

  def handle(:corp, {global_id}, token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/arena/get-crops-by-global-id", %{globalId: global_id}, token)
    Enum.map(d, fn c -> %{
      corp_id: c |> Map.get("corpsId") |> String.to_integer,
      pvp_type: c |> Map.get("pvpType"),
      name: c |> Map.get("corpsName"),
      zone: c |> Map.get("zone"),
      server: c |> Map.get("server"),
    } end)
  end

  def handle(:role_history, {global_id}, token) do
    handle(:role_history, {global_id, 0, 100}, token)
  end

  def handle(:role_history, {global_id, cursor, size}, token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/match/history", %{global_role_id: global_id, cursor: cursor, size: size}, token)
    d |> Enum.map(fn m ->
      %{
        match_id: m |> Map.get("match_id"),
        global_id: m |> Map.get("global_role_id"),
        avg_grade: m |> Map.get("avg_grade"),
        start_time: m |> Map.get("start_time"),
        end_time: m |> Map.get("end_time"),
        mvp: m |> Map.get("mvp"),
        won: m |> Map.get("won"),
        score_diff: m |> Map.get("mmr"),
        score: m |> Map.get("total_mmr"),
        kungfu: m |> Map.get("kungfu"),
      }
    end)
  end

  def handle(:match_replay, {match_id}, token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/match/replay", %{match_id: match_id}, token)
    Map.drop(d, ["skill_cate"])
  end

  def handle(:match_detail, {match_id}, token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/3c/mine/match/detail", %{match_id: match_id}, token)
    player_of = fn i -> fn pi ->
      %{
        team: i,
        global_id: pi |> Map.get("global_role_id"),
        role_id: pi |> Map.get("role_id"),
        zone: pi |> Map.get("zone"),
        server: pi |> Map.get("server"),
        kungfu: pi |> Map.get("kungfu_id"),
        score: pi |> Map.get("mmr"),
        score2: pi |> Map.get("score"),
        ranking: pi |> Map.get("ranking"),
        equip_score: pi |> Map.get("equip_score"),
        equip_addition_score: Map.get(pi, "equip_strength_score") + Map.get(pi, "stone_score"),
        max_hp: pi |> Map.get("max_hp"),
        metrics: pi |> Map.get("metrics") |> Enum.map(fn m -> m |> Map.get("value") end),
        equips: pi |> Map.get("armors") |> Enum.map(fn e -> e |> Map.get("ui_id") |> String.to_integer end),
        talents: pi |> Map.get("talents") |> Enum.map(fn t -> t |> Map.get("id") |> String.to_integer end),
        attrs: pi |> Map.get("body_qualities") |> Enum.map(fn a -> a |> Map.get("value") end),
      }
    end end
    %{
      match_id: d |> Map.get("match_id"),
      start_time: d |> Map.get("basic_info") |> Map.get("start_time"),
      duration: d |> Map.get("basic_info") |> Map.get("duration"),
      map: d |> Map.get("basic_info") |> Map.get("map") |> String.to_integer,
      pvp_type: d |> Map.get("basic_info") |> Map.get("type"),
      grade: d |> Map.get("basic_info") |> Map.get("grade"),
      total_score1: d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(fn pi -> pi |> Map.get("score") end) |> Enum.sum,
      total_score2: d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(fn pi -> pi |> Map.get("score") end) |> Enum.sum,
      team1: d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(fn pi ->
        pi |> Map.get("kungfu_id")
      end),
      team2: d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(fn pi ->
        pi |> Map.get("kungfu_id")
      end),
      winner: d |> Map.get("team1") |> Map.get("won") && 1 || 2,
      roles: (d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(player_of.(1)))
          ++ (d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(player_of.(2))),
    }
  end
end
