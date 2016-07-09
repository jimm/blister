defmodule Blister.GUI do

  @callback start_link() :: any
  @callback update() :: :ok
  @callback getch() :: integer
  @callback help(String.t) :: :ok
  @callback cleanup() :: :ok

end
