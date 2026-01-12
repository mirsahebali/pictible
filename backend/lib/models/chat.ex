defmodule Pictible.Models.Chat do
  use Ecto.Schema

  import Ecto.Changeset

  schema "chats" do
    field :message, :string
    field :sent_at, :utc_datetime

    belongs_to :room, Pictible.Models.Room
    belongs_to :player, Pictible.Models.Player
  end

  def changeset(chat, params) do
    chat
    |> cast(params, [:message, :sent_at])
    |> validate_required([:message, :sent_at])
  end

  @spec to_map(%Pictible.Models.Chat{}) :: map()
  def to_map(chat) do
    encoded_map = %{
      id: chat.id,
      sent_at: chat.sent_at,
      message: chat.message,
      username: chat.player.username,
    }
    encoded_map
  end
end
