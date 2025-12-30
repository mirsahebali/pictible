defmodule Pictible.MixProject do
  use Mix.Project

  def project do
    [
      app: :pictible,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pictible.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.22.0"},
      {:bandit, "~> 1.0"},
      {:websock_adapter, "~> 0.5.9"},
      {:jason, "~> 1.4.4"}
    ]
  end
end
