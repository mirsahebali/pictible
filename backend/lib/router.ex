defmodule Pictible.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static,
    at: "/",
    from: {:pictible, "priv/static"},
    only: ~w(_app robots.txt)

  plug Plug.Static,
    at: "/room",
    from: {:pictible, "priv/static"},
    only: ~w(_app robots.txt)

  plug :match
  plug :dispatch


  get "/ws-test" do
    send_resp(conn, 200, "connect to ws")
  end

  get "/ws/:sock_id" do
    IO.inspect(sock_id, label: "Sock")
    conn 
    |> WebSockAdapter.upgrade(Pictible.EchoWS, [], timeout: 600_000)
  end

  get "/room-ws/:room_code/:username" do
    conn 
    |> WebSockAdapter.upgrade(Pictible.EventSocket, %{room_code: room_code, drawing_state: :idle, username: username}, timeout: 6000_000)
  end

  forward "/api", to: Pictible.ApiRouter

  # 👇 SPA fallback MUST be a route
  get _ do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(
      200,
      Path.join(:code.priv_dir(:pictible), "static/index.html")
    )
  end
end
