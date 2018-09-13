defmodule Jx3App.API do
  @moduledoc """
  Documentation for Crawler.
  """

  use GenServer
  require Logger
  alias Jx3App.{Const, Utils}

  def start_link(cred, opts) do
    GenServer.start_link(__MODULE__, cred, opts)
  end

  def lookup do
    GenServer.whereis(__MODULE__)
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
      %{} -> Map.put(d, :ts, Utils.timestamp())
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
      {:error, err} -> {:error, {:encode, err}}
      {:ok, body} ->
        case HTTPoison.post(url, body, option) do
          {:error, err} -> {:error, {:post, err}}
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            case Poison.decode body do
              {:error, err} -> {:error, {:decode, err}}
              {:ok, o} -> case o do
                %{"code" => 0, "data" => data} -> {:ok, data}
                %{"msg" => msg} -> {:error, {:result, msg}}
              end
            end
          {:ok, %HTTPoison.Response{status_code: code} = resp} ->
            Logger.warn(inspect(resp))
            {:error, {:http_code, code}}
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
  def init(opts \\ []) do
    with {:ok, u} <- Keyword.fetch(opts, :username),
      {:ok, p} <- Keyword.fetch(opts, :password),
      id <- Keyword.get(opts, :deviceid, "CURL"),
      token <- login(u, p, id)
    do
      sleep = Keyword.get(opts, :sleep, 300)
      {:ok, %{token: token, last: NaiveDateTime.utc_now, sleep: sleep}}
    else
      _ -> :error
    end
  end

  @impl true
  def handle_call(req, from, %{token: token, last: last, sleep: sleep} = state) do
    :timer.sleep(max(0, sleep - NaiveDateTime.diff(NaiveDateTime.utc_now, last, :millisecond)))
    try do
      {:reply, handle(elem(req, 0), Tuple.delete_at(req, 0), token), %{state | last: NaiveDateTime.utc_now, sleep: 100}}
    rescue e ->
      Logger.error(
        "JX3APP: " <> Exception.format(:error, e, __STACKTRACE__) <> "\n" <>
        "Last message: " <> inspect(req) <> "\n" <>
        "State: " <> inspect(state) <> "\n" <>
        Utils.format_client(from)
      )
      {:reply, nil, %{state | last: NaiveDateTime.add(NaiveDateTime.utc_now, 3)}}
    end
  end

  def handle(:sleep, {time}, _) do
    Process.sleep(time*1000)
    :ok
  end

  @not_nil_tags ~w(corp role_history role_info person_roles match_detail match_replay)a
  def handle(tag, {nil}, _) when tag in @not_nil_tags, do: nil
  def handle(tag, {""}, _) when tag in @not_nil_tags, do: nil

  def handle(:top200, {match_type}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/#{match_type}/mine/arena/top200", %{})
    d |> Enum.map(fn p ->
      r = Map.get(p, "personInfo")
      %{
        role_info: %{
          passport_id: Map.get(p, "passportId") |> Utils.empty_nil,
          global_id: Map.get(p, "globalId") |> Utils.empty_nil, # assert == Map.get(r, gameGlobalRoleId)
          role_id: case Map.get(r, "gameRoleId") do
            "" -> nil
            i -> i |> String.to_integer
          end,
          name: Map.get(r, "roleName") |> Utils.empty_nil,
          server: Map.get(r, "server") |> Utils.empty_nil,
          zone: Map.get(r, "zone") |> Utils.empty_nil,
          force: Map.get(r, "force") |> Utils.empty_nil,
          body_type: Map.get(r, "bodyType") |> Utils.empty_nil,
          camp: nil,
        },
        person_info: %{
          person_id: Map.get(p, "personId") |> Utils.empty_nil,
          name: Map.get(r, "person") |> Map.get("nickName") |> Utils.empty_nil,
          avatar: Map.get(r, "person") |> Map.get("avatarUrl") |> Utils.empty_nil,
          signature: Map.get(r, "person") |> Map.get("signature") |> Utils.empty_nil,
        }
      }
    end)
  end

  def handle(:person_info, {person_id}, token) do
    post("https://m.pvp.xoyo.com/socialgw/summary", %{personId: person_id}, token)
  end

  def handle(:person_roles, {person_id}, _) do
    {:ok, d} = post("https://m.pvp.xoyo.com/mine/role/person-roles", %{person_id: person_id})
    d |> Enum.map(fn r ->
      %{
        role_info: %{
          global_id: Map.get(r, "gameGlobalRoleId") |> Utils.empty_nil,
          role_id: case Map.get(r, "gameRoleId") do
            "" -> nil
            i -> i |> String.to_integer
          end,
          passport_id: Map.get(r, "passport_id") |> Utils.empty_nil,
          name: Map.get(r, "name") |> Utils.empty_nil,
          server: Map.get(r, "server") |> Utils.empty_nil,
          zone: Map.get(r, "zone") |> Utils.empty_nil,
          force: Map.get(r, "force") |> Utils.empty_nil,
          body_type: Map.get(r, "bodily") |> Utils.empty_nil, # nil
          camp: nil,
          level: Map.get(r, "level"),
          valid: Map.get(r, "valid"),
        },
        person_info: %{
          person_id: Map.get(r, "person_id") |> Utils.empty_nil,
          name: Map.get(r, "person_name") |> Utils.empty_nil,
          avatar: Map.get(r, "person_avatar") |> Utils.empty_nil,
          signature: nil,
        },
      }
    end)
  end

  def handle(:person_history, {person_id, cursor, size}, token) do
    post("https://m.pvp.xoyo.com/mine/match/person-history", %{personId: person_id, cursor: cursor, size: size}, token)
  end

  def handle(:role_info, {match_type, global_id}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/#{match_type}/mine/arena/find-role-gid", %{globalId: global_id})
    p = d["personInfo"]
    if p do
      %{
        role_info: %{
          global_id: Map.get(p, "gameGlobalRoleId") |> Utils.empty_nil,
          role_id: case Map.get(p, "gameRoleId") do
            "" -> nil
            i -> i |> String.to_integer
          end,
          passport_id: Map.get(d, "passportId") |> Utils.empty_nil,
          name: Map.get(p, "roleName") |> Utils.empty_nil,
          server: Map.get(p, "server") |> Utils.empty_nil,
          zone: Map.get(p, "zone") |> Utils.empty_nil,
          force: Map.get(p, "force") |> Utils.empty_nil,
          body_type: Map.get(p, "bodyType") |> Utils.empty_nil, # nil
          camp: nil,
        },
        person_info: %{
          person_id: Map.get(d, "personId") |> Utils.empty_nil,
          name: Map.get(p, "person") |> Map.get("nickName") |> Utils.empty_nil,
          avatar: Map.get(p, "person") |> Map.get("avatarUrl") |> Utils.empty_nil,
          signature: nil,
        },
      }
    end
  end

  def handle(:role_info, {role_id, zone, server}, _token) do
    {:ok, d} = post("https://m.pvp.xoyo.com/role/indicator", %{role_id: "#{role_id}", zone: zone, server: server})
    p = d["person_info"]
    r = d["role_info"]
    t = d["indicator"]
    if r == nil do nil
    else
      %{
        role_info: %{
          passport_id: nil,
          global_id: Map.get(r, "global_role_id") |> Utils.empty_nil,
          role_id: Map.get(r, "role_id") |> String.to_integer,
          name: Map.get(r, "name") |> Utils.empty_nil,
          server: Map.get(r, "server") |> Utils.empty_nil,
          zone: Map.get(r, "zone") |> Utils.empty_nil,
          force: Map.get(r, "force") |> Utils.empty_nil,
          body_type: Map.get(r, "body_type") |> Utils.empty_nil,
          camp: Map.get(r, "camp") |> Utils.empty_nil,
        },
        person_info: %{
          person_id: Map.get(p, "person_id") |> Utils.empty_nil,
          name: Map.get(p, "person_name") |> Utils.empty_nil,
          avatar: Map.get(r, "person_avatar") |> Utils.empty_nil,
          signature: nil,
        },
        indicator: t |> Enum.map(fn i ->
          %{
            match_type: Map.get(i, "type"),
            metrics: (Map.get(i, "metrics") || []) |> Enum.map(fn t ->
              {Map.get(t, "kungfu"), %{
                kungfu: Map.get(t, "kungfu"),
                mvp_count: Map.get(t, "mvp_count"),
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

  def handle(:role_history, {match_type, global_id}, token) do
    handle(:role_history, {match_type, global_id, 0, 100}, token)
  end

  def handle(:role_history, {match_type, global_id, cursor, size}, token) do
    size = size || 100
    {:ok, d} = post("https://m.pvp.xoyo.com/#{match_type}/mine/match/history", %{global_role_id: global_id, cursor: cursor, size: size}, token)
    d |> Enum.map(fn m ->
      %{
        match_id: m |> Map.get("match_id"),
        match_type: (m |> Map.get("pvp_type") |> Integer.to_string) <> Utils.get_zone_suffix(m |> Map.get("zone")),
        global_id: m |> Map.get("global_role_id"),
        avg_grade: m |> Map.get("avg_grade"),
        start_time: m |> Map.get("start_time"),
        end_time: m |> Map.get("end_time"),
        mvp: m |> Map.get("mvp"),
        won: m |> Map.get("won"),
        score_diff: m |> Map.get("mmr"),
        score: m |> Map.get("total_mmr"),
        kungfu: m |> Map.get("kungfu"),
        zone: m |> Map.get("zone"),
        server: m |> Map.get("server"),
      }
    end)
  end

  def handle(:match_replay, {match_type, match_id}, token) do
    {:ok, %{} = d} = post("https://m.pvp.xoyo.com/#{match_type}/mine/match/replay", %{match_id: match_id}, token)
    Map.drop(d, ["skill_cate"]) |> Map.put("match_type", match_type)
  end

  def handle(:match_detail, {match_type, match_id}, token) do
    {:ok, %{} = d} = post("https://m.pvp.xoyo.com/#{match_type}/mine/match/detail", %{match_id: match_id}, token)
    player_of = fn i -> fn pi ->
      kungfu = Map.get(pi, "kungfu_id")
      Const.push(:kungfu, kungfu, Map.get(pi, "kungfu"))
      metrics_version = Const.find_version(:metric_names,
        pi |> Map.get("metrics") |> Enum.map(&Utils.get_percent_name/1))
      attrs_version = Const.find_version(:attr_names,
        pi |> Map.get("body_qualities") |> Enum.map(&Utils.get_percent_name/1))
      %{
        team: i,
        global_id: pi |> Map.get("global_role_id"),
        role_id: pi |> Map.get("role_id"),
        name: pi |> Map.get("role_name"),
        zone: pi |> Map.get("zone"),
        server: pi |> Map.get("server"),
        kungfu: kungfu,
        score: pi |> Map.get("mmr"),
        score2: pi |> Map.get("score"),
        ranking: pi |> Map.get("ranking"),
        grade: min(max(trunc(Map.get(pi, "score") / 100) - 10, 0), 13),
        total_count: pi |> Map.get("total_count"),
        win_count: pi |> Map.get("win_count"),
        mvp_count: pi |> Map.get("mvp_count"),
        equip_score: pi |> Map.get("equip_score"),
        equip_addition_score: Map.get(pi, "equip_strength_score") + Map.get(pi, "stone_score"),
        max_hp: pi |> Map.get("max_hp"),
        metrics_version: metrics_version,
        metrics: pi |> Map.get("metrics") |> Enum.map(fn m -> m |> Map.get("value") end),
        equips: pi |> Map.get("armors") |> Enum.map(fn e ->
          id = e |> Map.get("ui_id") |> String.to_integer
          value = %{Map.drop(e, ["strength_evel", "strength_level", "permanent_enchant", "temporary_enchant", "mount1", "mount2", "mount3", "mount4", "mount5", "pos"]) | "icon" => Map.get(e, "icon") |> Utils.icon_url_trim}
          Const.push(:equip, id, value, :insert_only)
          id
        end),
        talents: pi |> Map.get("talents") |> Enum.map(fn t ->
          id = t |> Map.get("id") |> String.to_integer
          Const.push(:talent, id, %{Map.drop(t, ["level"]) | "icon" => Map.get(t, "icon") |> Utils.icon_url_trim}, :insert_only)
          id
        end),
        attrs_version: attrs_version,
        attrs: pi |> Map.get("body_qualities") |> Enum.map(fn a -> a |> Map.get("value") end),
      }
    end end
    %{
      match_id: d |> Map.get("match_id"),
      start_time: d |> Map.get("basic_info") |> Map.get("start_time"),
      duration: d |> Map.get("basic_info") |> Map.get("duration"),
      map: d |> Map.get("basic_info") |> Map.get("map") |> String.to_integer,
      pvp_type: d |> Map.get("basic_info") |> Map.get("type"),
      match_type: match_type,
      grade: d |> Map.get("basic_info") |> Map.get("grade"),
      total_score1: d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(fn pi -> pi |> Map.get("score") end) |> Enum.sum,
      total_score2: d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(fn pi -> pi |> Map.get("score") end) |> Enum.sum,
      team1: d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(fn pi ->
        pi |> Map.get("kungfu_id")
      end) |> Enum.sort,
      team2: d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(fn pi ->
        pi |> Map.get("kungfu_id")
      end) |> Enum.sort,
      winner: d |> Map.get("team1") |> Map.get("won") && 1 || 2,
      roles: (d |> Map.get("team1") |> Map.get("players_info") |> Enum.map(player_of.(1)))
          ++ (d |> Map.get("team2") |> Map.get("players_info") |> Enum.map(player_of.(2))),
    }
  end
end
