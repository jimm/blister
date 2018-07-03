defmodule Blister.MIDI.Input do
  use GenServer
  use Blister.MIDI.IO, type: :input
  require Logger

  defmodule State do
    defstruct [:io, :connections, :listener]
  end

  # ================ Public API ================

  def start_link(driver, name) do
    {:ok, in_pid} = driver.open(:input, name)
    listener = spawn_link(__MODULE__, :loop, [{nil, nil}])

    state = %State{
      io: %Blister.MIDI.IO{driver: driver, port_pid: in_pid, port_name: name},
      connections: [],
      listener: listener
    }

    {:ok, pid} = GenServer.start_link(__MODULE__, state)
    send(listener, {:set_state, {in_pid, pid}})
    :ok = driver.listen(in_pid, listener)
    {:ok, pid}
  end

  def add_connection(pid, connection) do
    GenServer.call(pid, {:add_connection, connection})
  end

  def remove_connection(pid, connection) do
    GenServer.call(pid, {:remove_connection, connection})
  end

  @doc "Used internally to process incoming MIDI messages."
  def receive_messages(pid, messages) do
    GenServer.call(pid, {:messages, messages})
  end

  # ================ GenServer ================

  def handle_call({:add_connection, conn}, _from, state) do
    {:reply, :ok, %{state | connections: [conn | state.connections]}}
  end

  def handle_call({:remove_connection, conn}, _from, state) do
    {:reply, :ok, %{state | connections: List.delete(state.connections, conn)}}
  end

  def handle_call({:messages, []}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:messages, messages}, _from, state) when is_list(messages) do
    messages = messages |> Enum.map(&remove_timestamp/1)
    state.connections |> Enum.map(&Blister.Connection.midi_in(&1, messages))
    {:reply, :ok, state}
  end

  def handle_cast(:stop, state) do
    send(state.listener, :stop)
    :ok = close(state)
    {:stop, :normal, nil}
  end

  # ================ Helpers ================

  defp remove_timestamp({{_, _, _}, t} = msg) when is_integer(t), do: msg
  defp remove_timestamp({_, _, _} = msg), do: msg

  # ================ PortMidi listener ================

  def loop({portmidi_input_pid, app_input_pid} = state) do
    receive do
      {^portmidi_input_pid, messages} ->
        receive_messages(app_input_pid, messages)
        loop(state)

      {:set_state, state} ->
        loop(state)

      :stop ->
        :ok
    end
  end
end
