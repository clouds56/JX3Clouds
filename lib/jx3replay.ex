defmodule Jx3replay do
  @moduledoc """
  Documentation for Jx3replay.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jx3replay.hello
      :world

  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    jx3app_args = Application.get_env(:jx3replay, Jx3APP)
    redix_args = Application.get_env(:jx3replay, Cache)[:redis] || []
    server_args = Application.get_env(:jx3replay, Server)[:cowboy] || []

    children = [
      # Define workers and child supervisors to be supervised
      # worker(BigLebowski.Worker, [arg1, arg2, arg3])
      worker(Model.Repo, [], restart: :transient),
      worker(Jx3Const, [], restart: :transient),
      worker(Jx3APP, [jx3app_args, [name: Jx3APP]], restart: :transient),
      :poolboy.child_spec(:redis_pool, [name: {:local, Redix}, worker_module: Redix, size: 5, max_overflow: 2], redix_args),
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Server, options: server_args),
      worker(Cache, [[name: Cache]], restart: :transient),
    ] ++ case Mix.env do
      :prod -> [worker(Crawler, [], restart: :transient),]
      _ -> []
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jx3replay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
