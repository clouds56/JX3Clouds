defmodule Model.Repo.Migrations.FixMatchTeam do
  use Ecto.Migration

  def change do
    change("match_2c")
    add_match_role_id("match_3c")
    change("match_5c")
    change("match_2d")
    change("match_3d")
    change("match_5d")
  end

  def change(prefix) do
    fix_reference(prefix)
    add_match_role_id(prefix)
  end

  def add_match_role_id(prefix) do
    rename table(:matches, prefix: prefix), :total_score1, to: :team1_score
    rename table(:matches, prefix: prefix), :total_score2, to: :team2_score
    rename table(:matches, prefix: prefix), :team1, to: :team1_kungfu
    rename table(:matches, prefix: prefix), :team2, to: :team2_kungfu
    alter table(:matches, prefix: prefix) do
      add :role_ids, {:array, :string}
    end
  end

  def quote_table(prefix \\ nil, source) do
    case prefix do
      nil -> ~s|"#{source}"|
      _ -> ~s|"#{prefix}"."#{source}"|
    end
  end

  def reference_name(table, column), do: ~s|"#{table}_#{column}_fkey"|

  def fix_reference(prefix) do
    create index(:matches, :start_time, prefix: prefix)

    alter table(:match_roles, prefix: prefix) do
      modify :match_id, references(:matches, column: :match_id, type: :bigint), from: :bigint
      # modify :role_id, references(:roles, column: :global_id, type: :string, prefix: :public), from: :string
    end
    execute ~s|alter table #{quote_table(prefix, :match_roles)} add constraint #{reference_name(:match_roles, :role_id)}
                foreign key (#{:role_id}) REFERENCES #{quote_table(:roles)}(#{:global_id})|,
            ~s|alter table #{quote_table(prefix, :match_roles)} drop constraint #{reference_name(:match_roles, :role_id)}|
    create index(:match_roles, :role_id, prefix: prefix)

    alter table(:match_logs, prefix: prefix) do
      modify :match_id, references(:matches, column: :match_id, type: :bigint), from: :bigint
    end
  end
end
