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
    "#{pad_int(y, 4)}#{pad_int(m, 2)}#{pad_int(d, 2)}#{pad_int(hh, 2)}#{pad_int(mm, 2)}#{pad_int(ss, 2)}.#{pad_int(ms, 3) |> String.slice(0..2)}"
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
    _post(url, body, [:token, token])
  end

  def post(url, body) do
    _post(url, body, [])
  end
end
