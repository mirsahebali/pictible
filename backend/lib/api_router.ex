defmodule Pictible.ApiRouter do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch
  

  get "/health" do 
    send_resp(conn, 200, "API is up\n")
  end
end
