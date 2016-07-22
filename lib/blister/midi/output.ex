defmodule Blister.MIDI.Output do
  use GenServer
  use Blister.MIDI.IO

  defmodule State do
    defstruct [:io]
  end

  # ================ Public API ================
  #
  # See also Blister.MIDI.IO

  def start_link(driver, name) do
    {:ok, out_pid} = driver.open(:output, name)
    GenServer.start_link(__MODULE__,
      %State{io: %Blister.MIDI.IO{driver: driver, port_pid: out_pid,
                                  port_name: name}})
  end

  def write(pid, messages), do: GenServer.cast(pid, {:write, messages})

  # ================ GenServer ================

  def handle_cast({:write, messages}, state) do
    state.io.driver.write(state.io.port_pid, messages)
  end

  def handle_cast(:stop, state) do
    send(state.listener, :stop)
    :ok = state.io.driver.close(:output, state.io.port_pid)
    {:stop, :normal, nil}
  end
end
