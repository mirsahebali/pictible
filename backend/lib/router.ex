defmodule Pictible.Router do
  use Plug.Router

  plug Plug.Static,
    at: "/",
    from: :pictible,
    headers: (if Mix.env() == :dev, do: %{"Access-Control-Allow-Origin" => "*"}, else: nil)

  plug Plug.Logger
  plug :match
  plug :dispatch

  forward "/api", to: Pictible.ApiRouter

  match _ do 
    send_file(conn, 200, Path.join(:code.priv_dir(:pictible), "static/index.html"))
  end

end
