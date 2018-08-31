defmodule Jx3Const do
  @name __MODULE__

  def start_link() do
    Agent.start_link(fn -> load() end, name: @name)
  end

  def encode_key(key) do
    inspect(key)
  end

  def decode_key(key) do
    cond do
      String.starts_with?(key, "\"") -> String.slice(key, 1, String.length(key)-1)
      String.starts_with?(key, ":") -> String.slice(key, 1) |> String.to_atom
      true -> try do String.to_integer(key) rescue _ -> key end
    end
  end

  def get(tag, key) do
    Agent.get_and_update(@name, fn state -> 
      case Map.get(state, tag, nil) do
        %{} = t -> {Map.get(t, key, nil), state}
        nil -> {nil, Map.put(state, tag, %{})}
      end
    end)
  end

  defp push_(tag, key, value) do
    Model.Query.update_item(%{tag: tag, id: encode_key(key), content: value})
    Agent.update(@name, fn state -> 
      case Map.get(state, tag, nil) do
        %{} -> put_in(state, [tag, key], value)
        nil -> Map.put(state, tag, %{key => value})
      end
    end)
  end

  def push(tag, key, value, type \\ :overwrite) do
    case {type, get(tag, key)} do
      {:insert_only, nil} -> push_(tag, key, value)
      {:force, _} -> push_(tag, key, value)
      {:overwrite, x} when x != value ->
        IO.inspect(x)
        IO.inspect(value)
        push_(tag, key, value)
      _ -> nil
    end
  end

  def reload do
    Agent.update(@name, fn _ -> load() end)
  end

  def show do
    Agent.get(@name, fn s -> s end)
  end

  def load(tag \\ nil) do
    Model.Query.get_items(tag)
    |> Enum.map(fn {t, l} ->
      {String.to_atom(t), Enum.map(l, fn i -> {decode_key(i.id), i.content} end) |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end
end
