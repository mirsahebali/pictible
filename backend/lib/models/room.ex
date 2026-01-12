defmodule Pictible.Models.Room do

  use Ecto.Schema

  alias Pictible.Models.Player
  alias Pictible.Models.Chat
  import Ecto.Changeset

  schema "rooms" do
    field :room_code, :string

    has_many :players, Player
    has_many :chats, Chat
    timestamps()
  end

  def changeset(room, params \\ %{})do
    room 
    |> cast(params, [:room_code])
    |> validate_required([:room_code])
  end

  @spec to_map(map()) :: map()
  def to_map(room) do
    encoded_map = %{
      id: room.id,
      room_code: room.room_code,
      inserted_at: room.inserted_at,
      updated_at: room.updated_at,
    }

    if room.players != nil do
      players = Enum.map(room.players, fn player -> 
        Player.to_map(player)
      end)
      Map.put(encoded_map, :players, players)
    else 
      encoded_map
    end
  end
end
