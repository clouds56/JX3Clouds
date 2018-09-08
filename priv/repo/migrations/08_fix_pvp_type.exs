defmodule Model.Repo.Migrations.FixPvpType do
  use Ecto.Migration

  def change do
    schema "match_3c", type: :move

    schema "match_2c", src: "match_3c"
    schema "match_5c", src: "match_3c"
    schema "match_2d", src: "match_3c"
    schema "match_3d", src: "match_3c"
    schema "match_5d", src: "match_3c"
    schema "match_2m", src: "match_3c"
    schema "match_3m", src: "match_3c"
    schema "match_5m", src: "match_3c"
  end

  def schema(name, opts \\ []) do
    src = opts[:src] || "public"
    table_fun = case opts[:type] || :like do
      :like -> &table_like/3
      :move -> &table_move/3
    end
    execute ~s|create schema "#{name}"|, ~s|drop schema #{name}|
    # table_like(name, src, :scores)
    table_fun.(name, src, :matches)
    table_fun.(name, src, :match_roles)
    table_fun.(name, src, :match_logs)
  end

  def quote_table(prefix \\ nil, source) do
    case prefix do
      nil -> ~s|"#{source}"|
      _ -> ~s|"#{prefix}"."#{source}"|
    end
  end

  def table_move(dst, src, table_name) do
    execute ~s|alter table #{quote_table(src, table_name)} set schema "#{dst}"|,
            ~s|alter table #{quote_table(dst, table_name)} set schema "#{src}"|
    # execute ~s|create table #{quote_table(src, table_name)} (like #{quote_table(dst, table_name)} including all)|,
    #         ~s|drop table #{quote_table(src, table_name)}|
  end

  def table_like(dst, src, table_name) do
    execute ~s|create table #{quote_table(dst, table_name)} (like #{quote_table(src, table_name)} including all)|,
            ~s|drop table #{quote_table(dst, table_name)}|
  end
end
