defmodule Jx3App.Const do
  @name __MODULE__

  alias Jx3App.Model

  def start_link() do
    Agent.start_link(fn -> load() end, name: @name)
  end

  def encode_key(key) do
    inspect(key)
  end

  def decode_key(key) do
    cond do
      String.starts_with?(key, "\"") -> String.slice(key, 1..-2)
      String.starts_with?(key, ":") -> String.slice(key, 1..-1) |> String.to_atom
      true -> try do String.to_integer(key) rescue _ -> key end
    end
  end

  def get(tag, key) do
    Agent.get(@name, fn {items, _} ->
      case Map.get(items, tag, nil) do
        %{} = t -> Map.get(t, key, nil)
        nil -> nil
      end
    end)
  end

  def find(tag, value) do
    Agent.get_and_update(@name, fn {items, index} = state ->
      case Map.get(index, tag, nil) do
        %{} = t -> {Map.get(t, value, nil), state}
        nil ->
          case Map.get(items, tag, nil) do
            %{} = t ->
              index = Map.put(index, tag, Enum.map(t, fn {k, v} -> {v, k} end) |> Enum.into(%{}))
              {get_in(index, [tag, value]), {items, index}}
            nil -> {nil, state}
          end
      end
    end)
  end

  defp push_(tag, key, value) do
    Model.Query.update_item(%{tag: tag, id: encode_key(key), content: value})
    Agent.update(@name, fn {items, index} ->
      case Map.get(items, tag, nil) do
        %{} ->
          items = put_in(items, [tag, key], value)
          index = case Map.get(index, tag, nil) do
            %{} -> put_in(index, [tag, value], key)
            nil -> index
          end
          {items, index}
        nil -> {Map.put(items, tag, %{key => value}), index}
      end
    end)
  end

  def push(tag, key, value, type \\ nil) do
    type = cond do
      type == nil and tag == :version -> :version
      type == nil -> :overwrite
      true -> type
    end
    case {type, get(tag, key)} do
      {:insert_only, nil} -> push_(tag, key, value)
      {:insert_only, _} -> :ok
      {:force, _} -> push_(tag, key, value)
      {:overwrite, x} when x != value ->
        IO.inspect(x)
        IO.inspect(value)
        push_(tag, key, value)
      {:overwrite, _} -> :ok
      {:version, nil} ->
        push_(tag, key, 1)
        push_(key, 0, value)
      {:version, v} ->
        if !find(tag, value) do
          push_(tag, key, v+1)
          push_(key, v, value)
        end
      _ -> :error
    end
  end

  def find_version(tag, value) do
    case find(tag, value) do
      nil ->
        push(:version, tag, value)
        find(tag, value)
      x -> x
    end
  end

  def reload do
    Agent.update(@name, fn _ -> load() end)
  end

  def show do
    Agent.get(@name, fn s -> s end)
  end

  def load(tag \\ nil) do
    items = Model.Query.get_items(tag)
    |> Enum.map(fn {t, l} ->
      {String.to_atom(t), Enum.map(l, fn i -> {decode_key(i.id), i.content} end) |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
    {items, %{}}
  end
end
