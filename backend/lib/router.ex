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

  get "/ws-test" do
    send_resp(conn, 200, "connect to ws")
  end

  get "/ws/:sock_id" do
    IO.inspect(sock_id, label: "Sock")
    conn 
    |> WebSockAdapter.upgrade(Pictible.EchoWS, [], timeout: 600_000)
  end

  get "/room-ws/:room_code/:username" do
    player_id = ""
    conn 
    |> WebSockAdapter.upgrade(Pictible.EventSocket, %{room_code: room_code, curr_player: player_id, drawing_state: :idle, username: username}, timeout: 6000_000)
  end

  match _ do 
    send_file(conn, 200, Path.join(:code.priv_dir(:pictible), "static/index.html"))
  end

end


