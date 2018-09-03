defmodule Cache do
  require Logger
  import Ecto.Query
  alias Model.{Repo, Person, Role, RolePerformance, Match, MatchRole}

  defmodule Store do
    def exec(command) do
      :poolboy.transaction(Redix, fn pid ->
        Redix.command(pid, command)
      end)
    end

    def multi(commands) do
      :poolboy.transaction(Redix, fn pid ->
        Redix.pipeline(pid, commands)
      end)
    end

    @expire_time 300

    def get_ttl_key(name, fun_query, opts \\ []) do
      value_key = opts[:value_key] || "#{name}:value"
      time_key = opts[:time_key] || "#{name}:time"
      is_expire = opts[:expire] || false
      expire_time = opts[:expire_time] || @expire_time
      fun_get = opts[:get] || &{:ok, &1}
      fun_set = opts[:set] ||
        case is_expire do
          false -> &["SET", &1, &2]
          true -> &["SETEX", expire_time, &1, &2]
        end
      fun_query = fun_query || fn -> :error end
      {:ok, time} = Store.exec(["GET", time_key])
      value =
        with {:ok, time} <- NaiveDateTime.from_iso8601(time || ""),
            true <- expire_time > 0 and Crawler.time_in?(time, expire_time),
            {:ok, value} <- Store.exec(["GET", value_key]),
            {:ok, value} <- fun_get.(value)
        do
          value
        else
          _ -> nil
        end
      with nil <- value,
          {:ok, value} <- fun_query.()
      do
        Logger.debug("Cache: save #{value_key}")
        Store.multi([
          fun_set.(value_key, value),
          ["SET", time_key, NaiveDateTime.to_iso8601(NaiveDateTime.utc_now)],
        ])
        {:ok, value}
      else
        _ ->
          value != nil && {:ok, value} || :error
      end
    end
  end

  def string_to_integer(s) do
    case Integer.parse(s) do
      {x, ""} -> {:ok, x}
      _ -> :error
    end
  end

  def count do
    ~w(roles persons matches fetched)a
    |> Enum.map(&{&1, count(&1)})
    |> Enum.into(%{})
  end

  def summary_role(role_id) do
    %{
      role_id: role_id,
      match_count: count({:role_matches, role_id}),
    }
  end

  def count(key, opts \\ []) do
    expire_time = opts[:expire_time] || 30
    is_expire = opts[:expire] || false
    key_str = "count:" <> cond do
      is_atom(key) or is_number(key) -> "#{key}"
      is_tuple(key) -> key |> Tuple.to_list |> Enum.map(fn i -> "#{i}" end) |> Enum.join(":")
      is_binary(key) -> key
    end
    case Store.get_ttl_key(key_str, fn -> {:ok, count_query(key)} end,
            expire_time: expire_time,
            is_expire: is_expire,
            get: &string_to_integer(&1 || ""))
    do
      {:ok, value} -> value
      _ -> nil
    end
  end

  def count_query(:roles) do
    Repo.aggregate(from(r in Role), :count, :global_id)
  end

  def count_query(:persons) do
    Repo.aggregate(from(p in Person), :count, :person_id)
  end

  def count_query(:matches) do
    Repo.aggregate(from(m in Match), :count, :match_id)
  end

  def count_query(:fetched) do
    Repo.aggregate(from(r in RolePerformance, where: not is_nil(r.fetch_at)), :count, :role_id)
  end

  def count_query({:role_matches, role_id}) do
    Repo.aggregate(from(r in MatchRole, where: r.role_id == ^role_id), :count, :match_id)
  end

  def partition(l, acc \\ [])
  def partition([], acc), do: Enum.reverse(acc)
  def partition([a, b | t], acc) do
    partition(t, [{a, b} | acc])
  end

  def show_all do
    foreach = fn keys, fun ->
      {:ok, result} = keys
        |> Enum.map(fun)
        |> Store.multi
      result
    end
    {:ok, keys} = Store.exec(["KEYS", "*"])
    types = keys |> foreach.(&["TYPE", &1])
    values = Enum.zip(keys, types) |> foreach.(fn {k, t} ->
      case t do
        "string" -> ["GET", k]
        "hash" -> ["HGETALL", k]
        "list" -> ["LRANGE", k, 0, -1]
        "set" -> ["SMEMBERS", k]
        "zset" -> ["ZRANGE", k, 0, -1, "WITHSCORES"]
      end
    end) |> Enum.zip(types) |> Enum.map(fn {v, t} ->
      case t do
        "string" -> v
        "hash" -> partition(v) |> Enum.into(%{})
        "list" -> v
        "set" -> v
        "zset" -> partition(v) |> Enum.map(fn {v1, v2} -> {v2, v1} end)
      end
    end)
    ttl = keys |> foreach.(&["TTL", &1])
    Enum.zip(keys, Enum.zip(Enum.zip(types, ttl), values)) |> Enum.into(%{})
  end
end
