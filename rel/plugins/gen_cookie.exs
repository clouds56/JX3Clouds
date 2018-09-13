defmodule Jx3App.Release.GenCookie do
  def gen(filename \\ nil) do
    Mix.Releases.Shell.info "Generating cookie.."
    cookie = :crypto.strong_rand_bytes(64) |> Base.encode64
    if filename != nil do
      :ok = File.write(filename, cookie)
      :ok = File.chmod(filename, 0o400)
    end
    cookie
  end

  def get(filename \\ "rel/secret.cookie") do
    cookie = case File.read("rel/secret.cookie") do
      {:ok, ""} -> gen()
      {:error, _} -> gen(filename)
      {:ok, c} -> c
    end
    :crypto.hash(:sha256, cookie <> "_cookie_salt") |> Base.encode16 |> String.to_atom
  end
end
