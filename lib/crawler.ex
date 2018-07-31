defmodule Crawler do
  @moduledoc """
  Documentation for Crawler.
  """

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
    "#{pad_int(y, 4)}#{pad_int(m, 2)}#{pad_int(d, 2)}#{pad_int(hh, 2)}#{pad_int(mm, 2)}#{pad_int(ss, 2)}#{pad_int(ms, 3) |> String.slice(0..2)}"
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

  def login(username, password) do
    {_, d} = post(
      "https://m.pvp.xoyo.com/user/login",
      %{
        passportId: username,
        password: :crypto.hash(:md5, password) |> Base.encode64,
      }
    )
    d |> Map.get("data", %{}) |> Map.get("token", "")
  end

  def top200 do
    post("https://m.pvp.xoyo.com/3c/mine/arena/top200", %{})
  end

  def person_info(person_id, token) do
    post("https://m.pvp.xoyo.com/socialgw/summary", %{personId: person_id}, token)
  end

  def person_summary(person_id, token) do
    post("https://m.pvp.xoyo.com/mine/match/person-history", %{personId: person_id}, token)
  end

  def match_replay(match_id, token) do
    post("https://m.pvp.xoyo.com/3c/mine/match/replay", %{match_id: match_id}, token)
  end

  def match_detail(match_id, token) do
    post("https://m.pvp.xoyo.com/3c/mine/match/detail", %{match_id: match_id}, token)
  end
end
