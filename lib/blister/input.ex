defmodule Blister.Input do
  use GenServer

  defmodule State do
    defstruct [:name, :input, :connections, :listener]
  end

  # ================ public API ================

  def start(name, connections, ticks_per_second) do
    {:ok, input} = PortMidi.open(:input, name)
    listener = spawn_link(Blister.Input, :loop, [{nil, nil}])
    state = %State{name: name,
                   input: input,
                   connections: connections,
                   listener: listener}
    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    send(listener, {:set_state, {input, pid}})
    :ok = PortMidi.listen(input, listener)
    {:ok, pid}
  end

  def name(pid) do
    GenServer.call(pid, :name)
  end

  def add_connection(pid, connection) do
    GenServer.cast(pid, {:add_connection, connection})
  end

  def remove_connection(pid, connection) do
    GenServer.cast(pid, {:remove_connection, connection})
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
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
    :ok = PortMidi.close(:input, state.input)
    {:stop, :normal, nil}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  # ================ PortMidi listener ================

  def loop({portmidi_input_pid, jex_input_pid}) do
    receive do
      {^portmidi_input_pid, messages} ->
        receive_messages(jex_input_pid, messages)
        loop({portmidi_input_pid, jex_input_pid})
      {:set_state, state} ->
        loop(state)
      :stop ->
        :ok
    end
  end
end
