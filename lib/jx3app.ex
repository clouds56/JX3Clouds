defmodule Jx3App.Application do
  use Application
  require Logger

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    Logger.info("start server with " <> inspect(args))

    api_args = Application.get_env(:jx3app, Jx3App.API)
    redix_args = Application.get_env(:jx3app, Jx3App.Cache)[:redis] || []
    server_args = Application.get_env(:jx3app, Jx3App.Server)[:cowboy] || []

    children = [
      # Define workers and child supervisors to be supervised
      # worker(BigLebowski.Worker, [arg1, arg2, arg3])
      worker(Jx3App.Model.Repo, [], restart: :transient),
      worker(Jx3App.Const, [], restart: :transient),
      worker(Jx3App.API, [api_args, [name: Jx3App.API]], restart: :transient),
    ] ++
    if Enum.any?([:all, :server, :cache], &(&1 in args)) do [
      :poolboy.child_spec(:redis_pool, [name: {:local, Jx3App.Cache.Redix}, worker_module: Redix, size: 5, max_overflow: 2], redix_args),
      :poolboy.child_spec(:cache_pool, [name: {:local, Jx3App.Cache}, worker_module: Jx3App.Cache, size: 5]),
    ] else [] end ++
    if Enum.any?([:all, :server], &(&1 in args)) do
      [Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Jx3App.Server, options: server_args),]
    else [] end ++
    if Enum.any?([:all, :crawler], &(&1 in args)) do
      [worker(Jx3App.Crawler, [], restart: :transient),]
    else [] end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jx3App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
