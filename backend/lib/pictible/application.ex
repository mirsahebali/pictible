defmodule Pictible.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    children = [
      {Bandit, plug: Pictible.Router, scheme: :http, port: 4069},
      Pictible.Repo,
      {Registry, keys: :duplicate, name: Pictible.WSRegistry},
      {Pictible.EventAgent, %{}},
      {Ecto.Migrator,
       repos: Application.fetch_env!(:pictible, :ecto_repos),
       skip: System.get_env("SKIP_MIGRATIONS") == "true"}
    ]

    opts = [strategy: :one_for_one, name: Pictible.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
