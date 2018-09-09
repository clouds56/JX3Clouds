defmodule Model.Repo.Migrations.FixMatchSchema do
  use Ecto.Migration

  def change do
    rename table(:scores), :pvp_type, to: :match_type
    rename table(:score_logs), :pvp_type, to: :match_type

    alter_type :scores, :match_type,
      from: {:integer, "translate(match_type, 'cdm', '')::integer"},
      to: {:varchar, "match_type::varchar || 'c'"}
    alter_type :score_logs, :match_type,
      from: {:integer, "translate(match_type, 'cdm', '')::integer"},
      to: {:varchar, "match_type::varchar || 'c'"}

    execute ~s/update scores set match_type = translate(match_type, 'cdm', '') || #{to_fragment("scores.role_id")};/, ""
    execute ~s/update score_logs set match_type = translate(match_type, 'cdm', '') || #{to_fragment("score_logs.role_id")};/, ""
  end

  def to_fragment(role_id \\ "role_id") do
    """
    (select case
      when position('电信' in zone) > 0 then 'c'
      when position('双线' in zone) > 0 then 'd'
      else 'm'
    end from roles where roles.global_id = #{role_id})
    """
  end

  def alter_type(table, column, opts \\ []) do
    {from_type, from_fragment} = opts[:from]
    {to_type, to_fragment} = opts[:to]

    execute ~s|alter table #{table} alter column #{column} type #{to_type} using #{to_fragment};|,
            ~s|alter table #{table} alter column #{column} type #{from_type} using #{from_fragment};|
  end
end
