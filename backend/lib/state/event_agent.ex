defmodule Pictible.EventAgent do
  use Agent

  def start_link(inital_value) when is_map(inital_value) do
    Agent.start_link(fn -> inital_value end, name: __MODULE__);
  end

  def get_room_data(room_code) when is_binary(room_code) do
    Agent.get(__MODULE__, fn data -> 
      data[room_code]
    end)
  end

  def add_new_room(room_code) when is_binary(room_code) do
    Agent.update(__MODULE__, fn data -> 
      data |> Map.put(room_code, :queue.new())
    end)
  end

  def enqueue(room_code, event_type, event_data) when is_binary(room_code) and is_binary(event_type) and is_map(event_data) do
    Agent.update(__MODULE__, fn data -> 
      new_data = {event_type, event_data}
      queue = Map.get(data, room_code)
      Map.put(data, room_code, :queue.in(new_data, queue))
    end)
  end

  def dequeue(room_code) when is_binary(room_code) do
    Agent.get_and_update(__MODULE__, fn data ->
      case Map.get(data, room_code) do
        {:empty, {[], []}} -> {nil, data}
        {[], []} -> {nil, data}
        queue when queue != {[], []} -> 
          {{:value, out_value}, queue} = :queue.out(queue)

          {out_value, Map.put(data, room_code, queue)}
      end
    end)
  end
end
