defmodule Pictible.EchoWS do

  def init(options) do
    {:ok, options}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    msg = %{:my_message => "pong"}

    encoded_msg = Jason.encode!(msg)

    {:reply, :ok, {:text, encoded_msg}, state}
  end

  def handle_in({data, [opcode: :text]}, state) do

    state |> IO.inspect(label: "State")

    data 
      |> Jason.decode!()
      |> IO.inspect()

    {:ok, state}
  end

  def terminate(:timeout, state) do
    {:ok, state}
  end

  def terminate(any_reason, state) do
    IO.inspect(any_reason)
    {:ok, state}
  end
end
