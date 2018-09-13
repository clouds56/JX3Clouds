defmodule Jx3App.Model.RoleLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jx3App.Model.{Role, DateRangeType}

  schema "role_logs" do
    belongs_to :role, Role, type: :string, references: :global_id, foreign_key: :global_id
    field :role_id, :id, default: 0
    field :name, :string, default: ""
    field :zone, :string, default: ""
    field :server, :string, default: ""
    field :seen, {:array, DateRangeType}
    timestamps()
  end

  @permitted ~w(role_id global_id name zone server seen)a

  def diff_date(%Ecto.Date{} = d1, %Ecto.Date{} = d2) do
    {:ok, d1} = d1 |> Ecto.Date.to_erl |> Date.from_erl
    {:ok, d2} = d2 |> Ecto.Date.to_erl |> Date.from_erl
    diff_date(d1, d2)
  end
  def diff_date(%Date{} = d1, %Date{} = d2) do
    Date.diff(d1, d2)
  end
  def diff_date(d1, d2) do
    {:ok, d1} = Ecto.Date.cast(d1)
    {:ok, d2} = Ecto.Date.cast(d2)
    diff_date(d1, d2)
  end

  def insert_seen(nil, [], acc) do
    Enum.reverse(acc)
  end
  def insert_seen(a, [], acc) do
    a = case a do
      {s, nil, nil} -> DateRangeType.cast([s, s], upper_inclusive: true)
      {_, l, nil} -> {:ok, l}
      {_, nil, r} -> {:ok, r}
      _ -> :error
    end
    case a do
      {:ok, day} -> [day | acc]
      _ -> insert_seen(nil, [], acc)
    end |> Enum.sort(fn i, j -> DateRangeType.compare(i, j) in [:lt, :eq] end)
  end
  def insert_seen(nil, [h | t], acc) do
    insert_seen(nil, t, [h | acc])
  end
  def insert_seen({nil, nil, nil}, t, acc) do
    insert_seen(nil, t, acc)
  end
  def insert_seen({s, l, r}, [h | t], acc) do
    {s, l, r, h} = cond do
      l == nil and r == nil and DateRangeType.in?(h, s) -> {nil, l, r, h}
      r == nil and h.lower_inclusive == false and s == h.lower -> {s, l, %{h | lower_inclusive: true}, nil}
      r == nil and h.lower_inclusive == true and diff_date(s, h.lower) == -1 -> {s, l, %{h | lower: s, lower_inclusive: true}, nil}
      l == nil and h.upper_inclusive == false and s == h.upper -> {s, %{h | upper_inclusive: true}, r, nil}
      l == nil and h.upper_inclusive == true and diff_date(s, h.upper) == 1 -> {s, %{h | upper: s, upper_inclusive: true}, r, nil}
      true -> {s, l, r, h}
    end
    if l != nil and r != nil do
      acc = [%{l | upper: r.upper, upper_inclusive: r.upper_inclusive} | acc]
      insert_seen(nil, t, h && [h | acc] || acc)
    else
      insert_seen({s, l, r}, t, h && [h | acc] || acc)
    end
  end

  def insert_seen(seen, a) do
    a = a || []
    case Ecto.Date.cast(seen) do
      {:ok, s} ->
        cond do
          Enum.any?(a, &DateRangeType.in?(&1, s)) -> a
          true -> insert_seen({s, nil, nil}, a, [])
        end
      _ -> a
    end
  end

  def changeset(role, change \\ :empty) do
    pre_seen = case role do
      %__MODULE__{} -> role.seen
      %Ecto.Changeset{} -> role.data.seen
      _ -> Map.get(role, :seen)
    end
    change = change
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    |> Map.put(:seen, insert_seen(change[:seen], pre_seen))
    case role do
      %__MODULE__{} -> cast(role, change, @permitted)
      _ -> cast(role, change, [:seen])
    end
  end
end
