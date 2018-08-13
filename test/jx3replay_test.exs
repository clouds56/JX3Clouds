defmodule Jx3replayTest do
  use ExUnit.Case
  doctest Jx3replay

  test "top200" do
    Crawler.top200
  end
end
