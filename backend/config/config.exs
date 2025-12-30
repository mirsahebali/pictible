import Config

config :pictible,
    ecto_repos: [Pictible.Repo]


config :pictible, Pictible.Repo,
    database: "pictible-#{Mix.env() |> to_string()}.db"
