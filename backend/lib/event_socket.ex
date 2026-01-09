defmodule Pictible.EventSocket do
  require Logger

  use Pictible.EventConsts
  alias Pictible.Models.Player
  alias Pictible.Models.Room

  import Ecto.Query

  def init(%{room_code: room_code, curr_player: "", drawing_state: :idle, username: username} = state) do
    Registry.register(Pictible.WSRegistry, room_code, %{username: username})
    {:ok, state}
  end

  def handle_in({data, [opcode: :text]}, state) do
    IO.inspect(Jason.decode!(data), label: "Data in ")

    Registry.dispatch(Pictible.WSRegistry, state[:room_code],  fn entries -> 
      for {pid, _meta} <- entries do

        if pid != self() do
          send(pid, {:broadcast, data})
        end
      end
    end)
    {:ok, state}
  end

  def handle_info({:broadcast, data}, state) do
    IO.inspect(data, label: "Handle Info Data")
    {:push, {:text, data}, state}
  end


  def terminate(_reason, state) do
    remove_player(state[:username])
    dispatch_player_left(state[:room_code], state[:username])
    delete_room(state[:room_code])
    {:ok, state}
  end

  defp remove_player(username) do
    player = Pictible.Repo.get_by(Player, username: username) 

    Pictible.Repo.delete(player) |> IO.inspect(label: "Deleted result")
  end

  defp dispatch_player_left(room_code, username) do
    Registry.dispatch(Pictible.WSRegistry, room_code,  fn entries -> 
      for {pid, _meta} <- entries do
        if pid != self() do
          send(pid, {:broadcast, Jason.encode!(%{"event" => @player_left, "data" => username})})
        end
      end
    end)
  end

  defp delete_room(room_code) do
    query = from r in Room, preload: [:players]

    room = Pictible.Repo.get_by(query, room_code: room_code) 
    if Enum.count(room.players) <= 0 do
      Pictible.Repo.delete(room) 
    end
  end
end
