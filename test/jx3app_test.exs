defmodule Jx3AppTest do
  use ExUnit.Case
  doctest Jx3App

  test "top200" do
    GenServer.call(API.lookup(), {:top200, "3d"})
  end
end
