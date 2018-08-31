defmodule Model.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :tag, :string, primary_key: true
      add :id, :string, primary_key: true
      add :content, :map
      timestamps()
    end
  end
end
