defmodule Model.Repo.Migrations.CreateRoleLogs do
  use Ecto.Migration

  def change do
    create table(:role_logs) do
      add :role_id, :id
      add :global_id, :string
      add :passport_id, :string
      add :name, :string
      add :zone, :string
      add :server, :string
      add :seen, {:array, :daterange}
      timestamps()
    end
    create index(:role_logs, :global_id)
    create index(:role_logs, [:role_id, :zone, :server])
    create unique_index(:role_logs, [:global_id, :role_id, :zone, :server, :name, :passport_id])
  end
end
