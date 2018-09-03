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
      fun_get = opts[:get] || fn i -> {:ok, i} end
      fun_set = opts[:set] ||
        case is_expire do
          false -> fn k, v -> ["SET", k, v] end
          true -> fn k, v -> ["SETEX", expire_time, k, v] end
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
    |> Enum.map(fn key -> {key, count(key)} end)
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
            get: fn i -> string_to_integer(i || "") end)
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

  def show_all do
    {:ok, keys} = Store.exec(["KEYS", "*"])
    {:ok, values} =
      keys
      |> Enum.map(fn i -> ["GET", i] end)
      |> Store.multi
    {:ok, ttl} =
      keys
      |> Enum.map(fn i -> ["TTL", i] end)
      |> Store.multi
    Enum.zip(keys, Enum.zip(ttl, values)) |> Enum.into(%{})
  end
end
