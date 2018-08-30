defmodule Jx3replayTest do
  use ExUnit.Case
  doctest Jx3replay

  test "top200" do
    GenServer.call(Crawler.lookup(), {:top200})
  end

  test "matches" do
    Crawler.foreach_role(&Crawler.matches(Crawler.lookup, &1))
  end
end
