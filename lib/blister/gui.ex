defmodule Blister.GUI do

  @callback start_link() :: any
  @callback update() :: :ok
  @callback getch() :: integer
  @callback prompt(String.t, String.t, String.t) :: {:ok, String.t} | nil
  @callback help(String.t) :: :ok
  @callback cleanup() :: :ok

end
