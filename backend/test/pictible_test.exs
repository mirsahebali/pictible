defmodule PictibleTest do
  use ExUnit.Case
  doctest Pictible

  test "greets the world" do
    assert Pictible.hello() == :world
  end
end
