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

  get "/summary/count" do
    send_resp(conn, 200, Poison.encode!(Cache.count, pretty: true) |> html)
  end

  get "/roles" do
    roles = Cache.roles
    resp = Poison.encode!(roles, pretty: true)
      |> format_replace(~r/("role_id":\s*")([^"]+)(",)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
      |> html
    send_resp(conn, 200, resp)
  end

  get "/role/:role_id" do
    role = Cache.summary_role(role_id)
    resp = Poison.encode!(role, pretty: true)
      |> format_replace(~r/("role_id":\s*")([^"]+)(",)/, &~s|<a href="/role/#{&1}">#{&1}</a>|)
      |> html
    send_resp(conn, 200, resp)
  end

  match _ do
    send_resp(conn, 404, "oops" |> html)
  end
end
