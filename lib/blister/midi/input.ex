defmodule Blister.MIDI.Input do
  use GenServer
  use Blister.MIDI.IO

  defmodule State do
    defstruct [:io, :connections, :listener]
  end

  # ================ Public API ================

  def start_link(name) do
    {:ok, in_pid} = PortMidi.open(:input, name)
    listener = spawn_link(__MODULE__, :loop, [{nil, nil}])
    state = %State{io: %Blister.MIDI.IO{port_pid: in_pid, port_name: name},
                   connections: [],
                   listener: listener}
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    send(listener, {:set_state, {in_pid, pid}})
    :ok = PortMidi.listen(in_pid, listener)
    {:ok, pid}
  end

  def add_connection(pid, connection) do
    GenServer.cast(pid, {:add_connection, connection})
  end

  def remove_connection(pid, connection) do
    GenServer.cast(pid, {:remove_connection, connection})
  end

  @doc "Used internally to process incoming MIDI messages."
  def receive_messages(pid, messages) do
    GenServer.cast(pid, {:messages, messages})
  end

  # ================ GenServer ================

  def handle_cast({:messages, []}, state) do
    {:noreply, state}
  end
  def handle_cast({:messages, messages}, state) do
    state.connections |> Enum.map(&(Blister.Connection.midi_in(&1, messages)))
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    send(state.listener, :stop)
    :ok = PortMidi.close(:input, state.io.port_pid)
    {:stop, :normal, nil}
  end

  # ================ PortMidi listener ================

  def loop({portmidi_input_pid, app_input_pid}) do
    receive do
      {^portmidi_input_pid, messages} ->
        receive_messages(app_input_pid, messages)
        loop({portmidi_input_pid, app_input_pid})
      {:set_state, state} ->
        loop(state)
      :stop ->
        :ok
    end
  end
end
