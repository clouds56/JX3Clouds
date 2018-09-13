defmodule Jx3App.Model.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Jx3App.Model.AnyType

  @primary_key false
  schema "items" do
    field :tag, :string, primary_key: true
    field :id, :string, primary_key: true
    field :content, AnyType
    timestamps()
  end

  @permitted ~w(content)a

  def changeset(item, change \\ :empty) do
    change = change
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
    cast(item, change, @permitted)
  end
end
