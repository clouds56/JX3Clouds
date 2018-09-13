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

    api_args = Application.get_env(:jx3app, API)
    redix_args = Application.get_env(:jx3app, Cache)[:redis] || []
    server_args = Application.get_env(:jx3app, Server)[:cowboy] || []

    children = [
      # Define workers and child supervisors to be supervised
      # worker(BigLebowski.Worker, [arg1, arg2, arg3])
      worker(Model.Repo, [], restart: :transient),
      worker(Const, [], restart: :transient),
      worker(API, [api_args, [name: API]], restart: :transient),
      :poolboy.child_spec(:redis_pool, [name: {:local, Redix}, worker_module: Redix, size: 5, max_overflow: 2], redix_args),
      :poolboy.child_spec(:cache_pool, [name: {:local, Cache}, worker_module: Cache, size: 5]),
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Server, options: server_args),
    ] ++ case args do
      [:all] -> [worker(Crawler, [], restart: :transient),]
      [:crawler] -> [worker(Crawler, [], restart: :transient),]
      _ -> []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jx3App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
