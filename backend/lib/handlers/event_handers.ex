defmodule Pictible.EventHandlers do
  require Logger
  use Pictible.EventConsts

  @moduledoc """
  # Possible events:

  ## Lobby Events
    - PlayerJoined = 0,
    - PlayerLeft = 1,
    - PlayerInvited = 2,
    - PlayerCurrentSelection = 3,

  ## Canvas events
    - PlayerDrawing = 4,
    - PlayerErasing = 5,
    - PlayerCleared = 6,
    - PlayerIdle = 7,

  ## Word Events
    - PlayerWordSelection = 8,
    - PlayerGuessed = 9,

    - NilEvent = 10,

      INFO: this event is sent to every client from server in every few seconds and if the client doesn't responds, we evict the client from db and room
    - CheckConnEvent = 11
  """


  @type event_type :: non_neg_integer()
  @type event_data :: map() | list() | nil
  @type reason :: binary() | map()
  @type event_result :: :ok | { :ok, reason } | { :error, reason }

  @spec handle_event(event_type, event_data) :: event_result

  def handle_event(@player_joined, data) when is_map(data) do
    Logger.info("Player joined: #{inspect(data)}")

    # handle player joining
  end

  def handle_event(@player_left, data) when is_map(data) do
    Logger.info("Player left: #{inspect(data)}")
    # handle player leaving
  end

  def handle_event(@player_invited, data) when is_map(data) do
    Logger.info("Player invited: #{inspect(data)}")
    # handle player invite
  end

  def handle_event(@player_current_selection, data) when is_map(data) do
    Logger.info("Player current selection: #{inspect(data)}")
    # handle current selection
  end

  def handle_event(@player_drawing, data) when is_list(data) or is_map(data) do
    Logger.info("Player drawing: #{inspect(data)}")
    # handle drawing
  end

  def handle_event(@player_erasing, data) when is_list(data) or is_map(data) do
    Logger.info("Player erasing: #{inspect(data)}")
    # handle erasing
  end

  def handle_event(@player_cleared, _data) do
    Logger.info("Canvas cleared")
    # handle clearing
  end


  def handle_event(@player_idle, _data) do
    Logger.info("Player Idle")
    :ok
  end

  def handle_event(@player_word_selection, data) when is_map(data) or is_list(data) do
    Logger.info("Word selected: #{inspect(data)}")
    # handle word selection
  end

  def handle_event(@player_guessed, data) when is_map(data) do
    Logger.info("Player guessed: #{inspect(data)}")
    # handle player guess
  end

  def handle_event(@nil_event, _data) do
    Logger.info("Nil event received")
    # handle nil event
  end

  def handle_event(@check_conn_event, _data) do
    Logger.info("Check conn event received")
    # handle nil event
  end

  def handle_event(invalid_event, data) do
    Logger.error("Invalid event: #{invalid_event} with data: #{inspect(data)}")
    # handle unrecognized event
  end
end
