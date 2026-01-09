defmodule Pictible.ApiRouter do

  require Logger
  use Plug.Router
  
  alias Pictible.Models.Player
  alias Pictible.Repo
  alias Pictible.Models.Room
  import Pictible.Utils

  import Ecto.Query

  plug Plug.Logger
  plug :match
  plug :dispatch
  

  get "/health" do 
    send_resp(conn, 200, "API is up\n")
  end
  
  get "/set/player/:room_code" do
    query = from Room, preload: [:players]
    result = Repo.get_by(query, room_code: room_code)
    active_idx = get_active_player_index(result.players)
    if not is_nil(active_idx) do
      result.players 
        |> Enum.with_index() 
        |> Enum.map(fn {player, index} -> 
            if index == active_idx do
              Player.changeset(player, %{active: false}) 
              |> Repo.update()
            end
            
            if index == active_idx + 1 do
              Player.changeset(player, %{active: true})
              |> Repo.update()
            end
          end) |> IO.inspect(label: "Update current player result")
    else
      List.first(result.players) 
      |> Player.changeset(%{active: true}) 
      |> Repo.update()
    end
    send_json_resp_data(conn, 200, "updated-player", false)
  end

  get "/room/:room_code" do
    query = from Room, preload: [:players]
    with result <- Repo.get_by(query, room_code: room_code), 
      false <- is_nil(result),
      mapped_data <- Room.to_map(result),
      {:ok, json_body} <- Jason.encode(mapped_data)
      do 
        send_json_resp_data(conn, 200, "room-get", false, json_body)
    else
      true -> send_json_resp_data(conn, 404, "room-not-found", true, nil)
    {:error, reason} -> 
      Logger.alert(reason)
      send_json_resp_data(conn, 402, "", true, nil)
    end
  end

  post "/join" do
    with {:ok, body, conn} <- read_body(conn, length: 1_0000),
      :ok <- validate_body(conn),
      json_body <- parse_body(body),
      true <- validate_json(json_body, [:username, :room_code]),
        IO.inspect(json_body),
      existing_room when not is_nil(existing_room) <- Pictible.Repo.get_by(Room, room_code: json_body["room_code"]),
      {:ok, _} <- (existing_room 
        |> Ecto.build_assoc(:players, username: json_body["username"], active: false) 
        |> Pictible.Repo.insert())
    do
      send_json_resp_data(conn, 200, "User Joined The Room", false)
    else
      {:error, reason} -> 
        Logger.alert("Invalid data was passed")
        IO.inspect(reason)
        send_json_resp_data(conn, 400, "Error adding user to the room")
      false -> 
        Logger.alert("Invalid Data")
        send_json_resp_data(conn, 400, "Error adding user to the room")
      nil -> 
        Logger.alert("Empty data retreieved")
        send_json_resp_data(conn, 404, "Error 404")
    end
  end

  post "/create" do
    case read_body(conn, length: 1_0000)  do
      # TODO: Make this a bit idiomatic
      {:ok, body, conn} -> 
        if not match?(:ok, validate_body(conn)) do
          Logger.alert("Invalid body not in text/plain: #{inspect(body)}") 
          send_json_resp_data(conn, 400, "Invalid request\n")
        else
          json_body  = parse_body(body)
          is_valid_json = json_body |> validate_json(:username)
          if not is_valid_json do

            Logger.alert("Invalid body not in correct json struct") 
            send_json_resp_data(conn, 400, "Invalid request\n")
          else


            room_code = random_hex(3)
            new_room = %Room{ 
                room_code: room_code,
                players: [%Player{
                username: json_body["username"],
                active: true,
                }
              ]
            }
            case (Pictible.Repo.insert(new_room)) do
              {:ok, room} -> 
                conn 
                |> put_resp_content_type("application/json") 
                |> send_json_resp_data(200, "Player Created", false, %{room_code: room_code, username: Enum.at(room.players, 0).username})
              {:error, _changeset} -> send_json_resp_data(conn, 400, "Error creating player")
            end

          end
        end
      _ -> send_json_resp_data(conn, 400, "Bad Room request\n")
    end
  end



  defp validate_json(json_body, [:username, :room_code])do
    IO.inspect(json_body, label: "JSON body")
    keys =  json_body |> Map.keys() 

    ((keys |> Enum.member?("username")) and (keys |> Enum.member?("room_code")))
  end

  defp validate_json(json_body, :username) do
    keys =  json_body |> Map.keys() 
    keys |> Enum.member?("username")
  end

  defp parse_body(body) do
    Jason.decode!(body)
  end

  defp validate_body(conn) do
    content_type = 
      conn 
      |> Plug.Conn.get_req_header("content-type") 
      |> List.first()

    {length, _} = 
      conn 
      |> Plug.Conn.get_req_header("content-length") 
      |> List.first() 
      |> Integer.parse()

    if check_text_plain_content(content_type) and valid_length(length) do
      :ok 
    else
      {:error, %{content_type: content_type, length: length}}
    end
  end

  defp valid_length(length), do: length <= 100 

  defp check_text_plain_content(value), do: String.contains?(value, "text/plain")  

  # TODO: if we get nil here, set any player to active
  defp get_active_player_index(players) do
    Enum.find_index(players, fn player -> player.active end)
  end
end
