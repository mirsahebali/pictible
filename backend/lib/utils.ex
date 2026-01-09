defmodule Pictible.Utils do
  @moduledoc false


  def is_dev do
    Mix.env() == :dev
  end

  def random_hex(bytes \\ 16) do
    bytes
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end


  def send_json_resp_data(conn, http_status_code, message, is_error \\ true, data \\ nil) do

    conn 
    |> Plug.Conn.send_resp(http_status_code, Jason.encode!(%{
        status_code: http_status_code, 
        is_error: is_error, 
        message: message,
        data: data
      }))
  end

end
