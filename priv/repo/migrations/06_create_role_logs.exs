defmodule Model.Repo.Migrations.CreateRoleLogs do
  use Ecto.Migration

  def change do
    create table(:role_logs) do
      add :role_id, :id, null: false
      add :global_id, :string, null: false
      add :name, :string, null: false
      add :zone, :string, null: false
      add :server, :string, null: false
      add :seen, {:array, :daterange}
      timestamps()
    end
    create index(:role_logs, :global_id)
    create index(:role_logs, [:role_id, :zone, :server])
    create unique_index(:role_logs, [:global_id, :role_id, :zone, :server, :name])

    create table(:role_passport_logs) do
      add :global_id, :string, null: false
      add :passport_id, :string, null: false
      timestamps(updated_at: false)
    end

    execute """
      CREATE FUNCTION roles_update_role_passport_logs_function()
      RETURNS TRIGGER AS $BODY$
      BEGIN
        IF ((TG_OP = 'INSERT' or NEW.passport_id <> OLD.passport_id) AND
            NEW.global_id IS NOT NULL AND NEW.passport_id IS NOT NULL) THEN
          INSERT INTO role_passport_logs (global_id, passport_id, inserted_at)
          VALUES (NEW.global_id, NEW.passport_id, now());
        END IF;
        RETURN NULL;
      END;
      $BODY$ LANGUAGE plpgsql;
    """, """
      DROP FUNCTION roles_update_role_passport_logs_function;
    """

    execute """
      CREATE TRIGGER roles_update_role_passport_logs AFTER INSERT OR UPDATE ON roles
      FOR EACH ROW EXECUTE PROCEDURE roles_update_role_passport_logs_function();
    """, """
      DROP TRIGGER roles_update_role_passport_logs ON roles;
    """
  end
end
