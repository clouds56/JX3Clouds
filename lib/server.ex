defmodule Jx3App.Server do
  use Plug.Router
  alias Jx3App.Cache

  plug :match
  plug :dispatch

  def html(str) do
    nav = [roles: "/roles", summary: "/summary/count"]
      |> Enum.map(fn {k, v} -> "<span><a href=#{v}>#{k}</a></span>" end)
      |> Enum.join(" ")
    """
    <body>
      <div>
        #{nav}
      </div>
      <pre>#{str}</pre>
    </body>
    """
  end
  def format_replace(str, regex, fun) do
    Regex.replace(regex, str, fn _, pre, mid, suf -> pre <> fun.(mid) <> suf end)
  end

  def format_html(str) do
    str |> format_role_id |> format_person_id |> format_name |> html
  end

  def format_role_id(str) do
    str
    |> format_replace(~r/("role_id":\s*")([^"]+)(",?)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
    |> format_replace(~r/("global_id":\s*")([^"]+)(",?)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
    |> format_replace(~r/(")<role_id>:([^"]+)(",?)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
  end
  def format_person_id(str) do
    format_replace(str, ~r/("person_id":\s*")([^"]+)(",?)/, &~s|<a href="/person/#{&1}">#{&1}</a>|)
  end
  def format_name(str) do
    Regex.replace(~r/(")<role_id_log:(?<id>[^>]+)>:([^"]+)(",?)/, str, ~S|\1<a href="/role/log/\2">\3</a>\4|)
  end

  get "/summary/count" do
    send_resp(conn, 200, Poison.encode!(
      Cache.call({:count}), pretty: true) |> html)
  end

  get "/roles" do
    roles = Cache.call({:roles})
    resp = Poison.encode!(roles, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  get "/role/log/:role_id" do
    role = Cache.call({:role_log, role_id})
    resp = Poison.encode!(role, pretty: true) |> format_html
    send_resp(conn, 200, resp)
  end

  get "/role/:role_id" do
    role = Cache.call({:role, role_id})
    case role do
      nil -> not_found(conn)
      _ ->
        role = role |> Map.put(:name, "<role_id_log:#{role[:role_id]}>:" <> role[:name])
        resp = Poison.encode!(role, pretty: true)
          |> format_html
        send_resp(conn, 200, resp)
    end
  end

  get "/person/:person_id" do
    person = Cache.call({:person, person_id})
    case person do
      nil -> not_found(conn)
      _ ->
        roles = person[:roles] |> Enum.map(fn [id|t] -> ["<role_id>:"<>id | t] end)
        resp = Poison.encode!(person |> Map.put(:roles, roles), pretty: true)
          |> format_html
        send_resp(conn, 200, resp)
    end
  end

  get "/search/role/:role_name" do
    roles = Cache.call({:search_role, role_name})
    resp = Poison.encode!(roles, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  get "/search/kungfu/:kungfu" do
    roles = Cache.call({:search_kungfu, kungfu})
    resp = Poison.encode!(roles, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  match _ do
    not_found(conn)
  end

  def not_found(conn) do
    send_resp(conn, 404, "not found" |> html)
  end
end
