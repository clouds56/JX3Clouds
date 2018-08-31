defmodule Model.Repo.Migrations.CreateIndicatorLogs do
  use Ecto.Migration

  def change do
    create table(:indicator_logs) do
      add :pvp_type, :integer
      add :score, :integer
      add :grade, :integer
      add :ranking, :integer
      add :total_count, :integer
      add :win_count, :integer
      add :mvp_count, :integer
      add :role_id, references(:roles, column: :global_id, type: :string)
      timestamps(updated_at: false)
    end

    create index("indicator_logs", [:role_id, :inserted_at])
  end
end