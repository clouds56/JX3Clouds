defmodule Model.Repo.Migrations.TransferRolePassportData do
  use Ecto.Migration
  require Logger
  import Ecto.Query

  defmodule RolePassportLog do
    use Ecto.Schema
    import Ecto.Changeset

    schema "role_passport_logs" do
      field :global_id, :string
      field :passport_id, :string
      Ecto.Schema.timestamps(updated_at: false)
    end
  end

  def up do
    from(r in Model.Role,
      where: not is_nil(r.passport_id),
      select: [:global_id, :passport_id, :updated_at])
    |> Model.Repo.all
    |> Enum.map(fn r ->
      %{global_id: r.global_id, passport_id: r.passport_id, inserted_at: r.updated_at}
    end) |> Enum.chunk_every(1000) |> Enum.map(&Model.Repo.insert_all(RolePassportLog, &1))
  end
  def down do

  end
end
