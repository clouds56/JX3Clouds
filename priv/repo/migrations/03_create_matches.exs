defmodule Model.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches, primary_key: false) do
      add :match_id, :bigint, primary_key: true
      add :start_time, :integer
      add :duration, :integer
      add :pvp_type, :integer
      add :map, :integer
      add :grade, :integer
      add :total_score1, :integer #add :team1_score, {:array, :integer}
      add :total_score2, :integer #add :team2_score, {:array, :integer}
      add :team1, {:array, :integer} #add :team1_kungfu, {:array, :integer}
      add :team2, {:array, :integer} #add :team2_kungfu, {:array, :integer}
      #add :role_ids, {:array, :string}
      add :winner, :integer

      timestamps(updated_at: false)
    end
    #create index(:matches, :start_time)

    create table(:match_roles, primary_key: false) do
      add :match_id, references(:matches, column: :match_id, type: :bigint), primary_key: true
      add :role_id, references(:roles, column: :global_id, type: :string), primary_key: true
      add :kungfu, :integer
      add :score, :integer
      add :score2, :integer
      add :ranking, :integer
      add :equip_score, :integer
      add :equip_addition_score, :integer
      add :max_hp, :integer
      add :metrics_version, :integer
      add :metrics, {:array, :float}
      add :equips, {:array, :integer}
      add :talents, {:array, :integer}
      add :attrs, {:array, :float}
      add :attrs_version, :integer

      timestamps(updated_at: false)
    end
    create index(:match_roles, :role_id)

    create table(:match_logs, primary_key: false) do
      add :match_id, references(:matches, column: :match_id, type: :bigint), primary_key: true
      add :replay, :map

      timestamps(updated_at: false)
    end
  end
end
