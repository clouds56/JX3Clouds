defmodule Server do
  use Plug.Router

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
    str |> format_role_id |> format_person_id |> html
  end

  def format_role_id(str) do
    str
    |> format_replace(~r/("role_id":\s*")([^"]+)(",?)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
    |> format_replace(~r/(")<role_id>:([^"]+)(",?)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
  end
  def format_person_id(str) do
    format_replace(str, ~r/("person_id":\s*")([^"]+)(",?)/, &~s|<a href="/person/#{&1}">#{&1}</a>|)
  end

  get "/summary/count" do
    send_resp(conn, 200, Poison.encode!(Cache.count, pretty: true) |> html)
  end

  get "/roles" do
    roles = Cache.roles
    resp = Poison.encode!(roles, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  get "/role/:role_id" do
    role = Cache.summary_role(role_id)
    resp = Poison.encode!(role, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  get "/person/:person_id" do
    person = Cache.summary_person(person_id)
    roles = person[:roles] |> Enum.map(fn [id|t] -> ["<role_id>:"<>id | t] end)
    resp = Poison.encode!(person |> Map.put(:roles, roles), pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  get "/search/role/:role_name" do
    roles = Cache.search_role(role_name)
    resp = Poison.encode!(roles, pretty: true)
      |> format_html
    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "oops" |> html)
  end
end
