defmodule Jx3replayTest do
  use ExUnit.Case
  doctest Jx3replay

  test "top200" do
    GenServer.call(Jx3APP.lookup(), {:top200})
  end
end
