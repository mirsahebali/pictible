defmodule Pictible.Repo do
  use Ecto.Repo,
    otp_app: :pictible,
    adapter: Ecto.Adapters.SQLite3
end
