defmodule Model.Repo.Migrations.CreateScoreLogs do
  use Ecto.Migration

  def change do
    create table(:scores, primary_key: false) do
      add :role_id, references(:roles, column: :global_id, type: :string), primary_key: true
      add :pvp_type, :integer, primary_key: true
      add :score, :integer
      add :score2, :integer
      add :grade, :integer
      add :ranking, :integer
      add :ranking2, :integer
      add :total_count, :integer
      add :win_count, :integer
      add :mvp_count, :integer
      add :fetch_at, :naive_datetime
      timestamps()
    end

    create index(:scores, :score)
    create index(:scores, :ranking)

    create table(:score_logs) do
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

    create index(:score_logs, [:role_id, :inserted_at])
  end
end
