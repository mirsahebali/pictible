defmodule Pictible.EventSocket do
  require Logger

  def init(%{room_code: room_code, curr_player: "", drawing_state: :idle} = state) do
    Registry.register(Pictible.WSRegistry, room_code, %{})
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
    {:push, {:text, data}, state}
  end

  def terminate(any_reason, state) do
    IO.inspect(any_reason, label: "Reason")
    IO.inspect(state, label: "State")
    {:ok, state}
  end
  
end
