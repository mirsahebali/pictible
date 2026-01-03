defmodule Pictible.EventSocket do
  require Logger

  def init(%{room_code: room_code, curr_player: "", drawing_state: :idle} = state) do
    Registry.register(Pictible.WSRegistry, room_code, %{})
    {:ok, state}
  end

  def handle_in({data, [opcode: :text]}, state) do
    data = IO.inspect(data, label: "Data IN")

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
    {:push, {:text, data}, state}
  end

  def terminate(any_reason, state) do
    Logger.info(any_reason)
    {:ok, state}
  end
  
end
