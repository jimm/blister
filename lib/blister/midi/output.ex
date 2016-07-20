defmodule Blister.MIDI.Output do
  use GenServer
  use Blister.MIDI.IO

  defmodule State do
    defstruct [:io]
  end

  # ================ Public API ================
  #
  # See also Blister.MIDI.IO

  def start_link(name) do
    {:ok, out_pid} = PortMidi.open(:output, name)
    GenServer.start_link(__MODULE__,
      %State{io: %Blister.MIDI.IO{port_pid: out_pid, port_name: name}})
  end

  def write(pid, messages), do: GenServer.cast(pid, {:write, messages})

  # ================ GenServer ================

  def handle_cast({:write, messages}, state) do
    PortMidi.write(state.io.port_pid, messages)
  end

  def handle_cast(:stop, state) do
    send(state.listener, :stop)
    :ok = PortMidi.close(:output, state.io.port_pid)
    {:stop, :normal, nil}
  end
end
