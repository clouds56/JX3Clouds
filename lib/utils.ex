defmodule Jx3App.Utils do
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

  def timestamp do
    %DateTime{year: y, month: m, day: d, hour: hh, minute: mm, second: ss, microsecond: {ms, _}} = DateTime.utc_now
    "#{pad_int(y, 4)}#{pad_int(m, 2)}#{pad_int(d, 2)}#{pad_int(hh, 2)}#{pad_int(mm, 2)}#{pad_int(ss, 2)}#{pad_int(ms, 6) |> String.slice(0..2)}"
  end

  def icon_url_trim(url) do
    r = Regex.run(~r|https://dl\.pvp\.xoyo\.com/prod/icons/([^?]*)\??.*|, url)
    if r do
      [_, r] = r
      r
    else
      url
    end
  end

  def get_percent_name(%{"name" => name, "value" => value}) when is_binary(value) do
    {_, y} = Float.parse(value)
    name <> y
  end
  def get_percent_name(%{"name" => name}), do: name

  def get_zone_suffix(zone) do
    case zone do
      nil -> ""
      "" -> ""
      "\u7535\u4FE1" <> _ -> "c"
      "\u53CC\u7EBF" <> _ -> "d"
      _ -> "m"
    end
  end

  def format_client({pid, _ref}) do
    "Client " <> inspect(pid) <> " is " <>
    case Process.alive?(pid) do
      true ->
        {_, st} = Process.info(pid, :current_stacktrace)
        "alive\n" <> Exception.format_stacktrace(st)
      _ -> "not alive"
    end
  end

  def unwrap({:ok, result}), do: result
  def unwrap(_), do: nil

  def unstruct(%_{} = o), do: Map.from_struct(o)
  def unstruct(%{} = o), do: o
  def unstruct(_), do: %{}

  def filter_into(a, b \\ %{}) do
    a |> Enum.filter(fn {_, v} -> v != nil end) |> Enum.into(b |> unstruct)
  end

  def time_in?(t, d, u \\ :second) do
    d = d * case u do
      :second -> 1
      :minute -> 60
      :hour -> 3600
      :day -> 24 * 3600
      :week -> 7 * 24 * 3600
    end
    case t do
      nil -> false
      _ -> NaiveDateTime.diff(NaiveDateTime.utc_now, t) <= d
    end
  end

  def count_word(l) do
    Enum.reduce(l, %{}, fn i, acc -> Map.update(acc, i, 1, &(&1 + 1)) end)
  end
end
