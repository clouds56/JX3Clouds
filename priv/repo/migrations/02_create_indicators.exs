defmodule Model.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:indicators) do
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

    create index("indicators", [:role_id, :inserted_at])
  end
end