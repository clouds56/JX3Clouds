defmodule Jx3App.MixProject do
  use Mix.Project

  def project do
    [
      app: :jx3app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Jx3App.Application, [:all]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:distillery, "~> 2.0"},
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:jason, "~> 1.1"},
      {:ecto, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:poolboy, "~> 1.5"},
      {:redix, "~> 0.7.1"},
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.6"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:dataloader, "~> 1.0"},
    ]
  end
end
