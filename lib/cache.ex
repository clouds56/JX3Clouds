defmodule Cache do
  def command(command) do
    :poolboy.transaction(Redix, fn pid ->
      Redix.command(pid, command)
    end)
  end
end