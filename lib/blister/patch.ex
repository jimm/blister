defmodule Blister.Patch do
  use GenServer

  defstruct name: "Unnamed",
    connections: [],
    start_messages: [],
    stop_messages: [],
    running: false

  # ================ API ================

  def start_link(patch) do
    GenServer.start_link(__MODULE__, %{patch | running: false})
  end

  def inputs(pid) do
    GenServer.call(pid, :inputs)
  end

  def name(pid) do
    GenServer.call(pid, :name)
  end

  def connections(pid) do
    GenServer.call(pid, :connections)
  end

  def start_messages(pid) do
    GenServer.call(pid, :start_messages)
  end

  def stop_messages(pid) do
    GenServer.call(pid, :stop_messages)
  end

  def start(nil) do
    :ok
  end
  def start(pid) do
    GenServer.call(pid, :start)
  end

  def stop(nil) do
    :ok
  end
  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  # ================ handlers ================

  alias Blister.Connection

  def handle_call(:inputs, _from, patch) do
    inputs = patch.connections |> Enum.map(&(&1.input)) |> Enum.uniq
    {:reply, inputs, patch}
  end

  def handle_call(:name, _from, patch) do
    {:reply, patch.name, patch}
  end

  def handle_call(:connections, _from, patch) do
    {:reply, patch.connections, patch}
  end

  def handle_call(:start_messages, _from, patch) do
    {:reply, patch.start_messages, patch}
  end

  def handle_call(:stop_messages, _from, patch) do
    {:reply, patch.stop_messages, patch}
  end

  def handle_call(:start, _from, %__MODULE__{running: true} = patch) do
    # already running
    {:reply, :ok, patch}
  end
  def handle_call(:start, _from, patch) do
    patch.connections |> Enum.map(&Connection.start(&1, patch.start_messages))
    {:reply, :ok, %{patch | running: true}}
  end

  def handle_call(:stop, _from, %__MODULE__{running: false} = patch) do
    # already stopped
    {:reply, :ok, patch}
  end
  def handle_call(:stop, _from, patch) do
    patch.connections |> Enum.map(&Connection.stop(&1, patch.stop_messages))
    {:reply, :ok, %{patch | running: false}}
  end
end
