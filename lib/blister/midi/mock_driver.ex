defmodule Blister.MIDI.MockDriver do

  require Logger

  # TODO save input and output messages so tests can inspect them

  # ================ API ================

  def start_link do
    state = %{input: [%{name: "input 1"}, %{name: "input 2"}],
              output: [%{name: "output 1"}, %{name: "output 2"}],
              listeners: %{}}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def devices do
    GenServer.call(__MODULE__, :devices)
  end

  def open(:input, name) do
    GenServer.call(__MODULE__, {:open, :input, name})
  end

  def open(:output, name) do
    GenServer.call(__MODULE__, {:open, :output, name})
  end

  def close(:input, pid) do
    GenServer.call(__MODULE__, {:close, :input, pid})
  end

  def close(:output, pid) do
    GenServer.call(__MODULE__, {:close, :output, pid})
  end

  def listen(in_pid, listener) do
    GenServer.call(__MODULE__, {:listen, in_pid, listener})
  end

  def write(out_pid, messages) do
    GenServer.call(__MODULE__, {:write, out_pid, messages})
  end

  @doc "Used for testing. Sends messages to in_pid."
  def input(in_pid, messages) do
    GenServer.call(__MODULE__, {:input, in_pid, messages})
  end

  # ================ Handlers ================

  def handle_call(:devices, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:open, :input, _name}, _from, state) do
    {:reply, {:ok, make_ref}, state}
  end

  def handle_call({:open, :output, _namename}, _from, state) do
    {:reply, {:ok, make_ref}, state}
  end

  def handle_call({:close, :input, _pid}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:close, :output, _pid}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:listen, in_pid, listener}, _from, state) do
    listeners =
      state.listeners
      |> Map.update(in_pid, [], fn ls -> [listener|ls] end)
    {:reply, :ok, %{state | listeners: listeners}}
  end

  def handle_call({:write, _in_pid, _messages}, _from, state) do
    # TODO remember what was written so tests can inspect
    {:reply, :ok, state}
  end

  @doc "Send `messages` to all listeners of `in_pid`."
  def handle_call({:input, in_pid, messages}, _from, state) do
    state.listeners
    |> Map.get(in_pid, [])
    |> Enum.each(fn listener ->
      send(listener, {in_pid, messages})
    end)
    {:reply, :ok, state}
  end

  def terminate(reason, state) do
    Logger.info("mock driver terminate")
    if state != :shutdown, do: Logger.info("mock driver reason #{inspect reason}")
  end
end
