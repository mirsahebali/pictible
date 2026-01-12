defmodule Pictible.EventHandlers do
  require Logger
  use Pictible.EventConsts

  import Ecto.Query
  alias Pictible.Models.Player
  alias Pictible.Repo

  @moduledoc """
  # Possible events:

  ## Lobby Events
      - PlayerJoined
      - PlayerLeft
      - PlayerInvited
      - PlayerSwitch

  ## Canvas events
      - PlayerDrawing
      - PlayerErasing
      - PlayerCleared
      - PlayerIdle
      - PlayerSentMessage

      - NilEvent

      - CheckConnEvent
  """


  @type event_type :: non_neg_integer()
  @type event_data :: map() | list() | nil
  @type reason :: binary() | map()
  @type event_result :: :ok | { :ok, reason } | { :error, reason }

  @spec handle_event(event_type, event_data) :: event_result

  def handle_event(@player_joined, data) when is_map(data) do
    Logger.info("Player joined: #{inspect(data)}")
    {:ok, data}
    # handle player joining
  end

  def handle_event(@player_left, data) when is_map(data) do
    Logger.info("Player left: #{inspect(data)}")
    {:ok, data}
  end

  def handle_event(@player_invited, data) when is_map(data) do
    Logger.info("Player invited: #{inspect(data)}")
    {:ok, data}
  end

  def handle_event(@player_switch, data) when is_map(data) do
    Logger.info("Player current selection: #{inspect(data)}")

    # handle current selection
    {:ok, data}
  end

  def handle_event(@player_drawing, data) when is_list(data) or is_map(data) do
    Logger.info("Player drawing: #{inspect(data)}")
    # handle drawing

    {:ok, data}
  end

  def handle_event(@player_erasing, data) when is_list(data) or is_map(data) do
    Logger.info("Player erasing: #{inspect(data)}")
    # handle erasing

    {:ok, data}
  end

  def handle_event(@player_cleared, data) do
    Logger.info("Canvas cleared")
    # handle clearing

    {:ok, data}
  end


  def handle_event(@player_idle, _data) do
    Logger.info("Player Idle")
    {:ok, :idle}
  end

  def handle_event(@player_sent_message, %{"message" => message, "username" => username} = data) when is_map(data) do
    Logger.info("Player sent message: #{inspect(data)}")

    query = from Player,
      where: [username: ^username],
      preload: [:room]

    player = Repo.one(query)
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    player 
    |> Ecto.build_assoc(:chats, message: message, sent_at: now, room_id: player.room.id) 
    |> Repo.insert()

    {:ok, :sent}
  end

  def handle_event(@nil_event, data) do
    Logger.info("Nil event received")

    {:ok, data}
  end

  def handle_event(invalid_event, data) do
    Logger.error("Invalid event: #{invalid_event} with data: #{inspect(data)}")

    {:error, data}
    # handle unrecognized event
  end
end
