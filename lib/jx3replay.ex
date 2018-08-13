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

    children = [
      # Define workers and child supervisors to be supervised
      # worker(BigLebowski.Worker, [arg1, arg2, arg3])
      worker(Model.Repo, []),
      worker(Crawler, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jx3replay.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
