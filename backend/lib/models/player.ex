defmodule Pictible.Models.Player do

  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :username, :string
    field :active, :boolean

    belongs_to :room, Pictible.Models.Room
    has_many :chats, Pictible.Models.Chat

    timestamps()
  end

  def changeset(player, params \\ %{})do
    player 
    |> cast(params, [:username, :active])
    |> validate_required([:username, :active])
  end

  @spec to_map(map()) :: map()
  def to_map(player) do
    encoded_map = %{
      id: player.id,
      username: player.username,
      active: player.active,
      inserted_at: player.inserted_at,
      updated_at: player.updated_at
    }

    encoded_map
  end

end
