defmodule Model.Repo.Migrations.CreateIndicatorLogs do
  use Ecto.Migration

  def change do
    create index(:roles, :person_id)

    create index(:scores, :score)
    create index(:scores, :ranking)

    create index(:matches, :start_time)
  end
end
