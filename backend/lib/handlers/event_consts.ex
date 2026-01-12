defmodule Pictible.EventConsts do

  @moduledoc false

  defmacro __using__(_) do
    quote do
      @player_joined 0
      @player_left 1
      @player_invited 2
      @player_switch 3
      @player_drawing 4
      @player_erasing 5
      @player_cleared 6
      @player_idle 7
      @player_sent_message 8
      @nil_event 9
    end
  end
end
