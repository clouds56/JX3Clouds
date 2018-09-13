defmodule Jx3App do
  @moduledoc """
  Documentation for Jx3App.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jx3App.hello
      :world

  """

  use Application

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    api_args = Application.get_env(:jx3app, Jx3App.API)
    redix_args = Application.get_env(:jx3app, Jx3App.Cache)[:redis] || []
    server_args = Application.get_env(:jx3app, Jx3App.Server)[:cowboy] || []

    children = [
      # Define workers and child supervisors to be supervised
      # worker(BigLebowski.Worker, [arg1, arg2, arg3])
      worker(Jx3App.Model.Repo, [], restart: :transient),
      worker(Jx3App.Const, [], restart: :transient),
      worker(Jx3App.API, [api_args, [name: Jx3App.API]], restart: :transient),
      :poolboy.child_spec(:redis_pool, [name: {:local, Jx3App.Cache.Redix}, worker_module: Redix, size: 5, max_overflow: 2], redix_args),
      :poolboy.child_spec(:cache_pool, [name: {:local, Jx3App.Cache}, worker_module: Jx3App.Cache, size: 5]),
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Jx3App.Server, options: server_args),
    ] ++ case args do
      [:all] -> [worker(Jx3App.Crawler, [], restart: :transient),]
      [:crawler] -> [worker(Jx3App.Crawler, [], restart: :transient),]
      _ -> []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jx3App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
