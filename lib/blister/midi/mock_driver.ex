defmodule Blister.MIDI.MockDriver do

  # ================ API ================

  def start_link do
    state = %{inputs: [%{name: "input 1", listeners: []}],
              outputs: [%{name: "input 2", listeners: []}]}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def devices, do: GenServer.call(__MODULE__, :devices)

  def open(:input, name), do: GenServer.call(__MODULE__, {:open, :input, name})

  def open(:output, name), do: GenServer.call(__MODULE__, {:open, :output, name})

  def close(:input, name), do: GenServer.call(__MODULE__, {:close, :input, name})

  def close(:output, name), do: GenServer.call(__MODULE__, {:close, :output, name})

  def listen(in_pid, listener), do: GenServer.call(__MODULE__, {:listen, in_pid, listener})

  def write(out_pid, messages), do: GenServer.call(__MODULE__, {:write, out_pid, messages})

  @doc "Used for testing. Sends messages to in_pid."
  def input(in_pid, messages), do: GenServer.call(__MODULE__, {:input, in_pid, messages})

  # ================ Handlers ================
  def handle_call(:devices, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:open, :input, name}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:open, :output, name}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:close, :input, name}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:close, :output, name}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:listen, in_pid, listener}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:write, in_pid, messages}, _from, state) do
    {:ok, state, state}
  end

  def handle_call({:input, :in_pid, messages}, _from, state) do
    {:ok, state, state}
  end
end
