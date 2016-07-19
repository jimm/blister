defmodule Blister.MIDI do
  use GenServer
  require Logger
  alias Blister.MIDI.{Input, Output, IO}

  # ================ Server ================

  def start_link do
    devices = PortMidi.devices

    # Returns a list of {name, pid} tuples
    outputs = devices.output |> Enum.map(fn d ->
      {:ok, output} = Output.start(d.name)
      {d.name, output}
    end)

    # Returns a list of {name, pid} tuples
    inputs = devices.input |> Enum.map(fn d ->
      {:ok, input} = Input.start(d.name)
      {d.name, input}
    end)

    state = %{inputs: inputs, outputs: outputs}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    Logger.info("midi init")
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  # ================ API ================

  @doc """
  Returns a list of {name, pid} tuples.
  """
  def inputs do
    GenServer.call(__MODULE__, :inputs)
  end

  def input(name) do
    GenServer.call(__MODULE__, {:input, name})
  end

  @doc """
  Returns a list of {name, pid} tuples.
  """
  def outputs do
    GenServer.call(__MODULE__, :outputs)
  end

  def output(name) do
    GenServer.call(__MODULE__, {:output, name})
  end

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
  end

  # ================ Handlers ================

  def handle_call(:inputs, _from, %{inputs: inputs} = state) do
    {:reply, inputs, state}
  end

  def handle_call({:input, name}, _from, %{inputs: inputs} = state) do
    input_pid = case inputs |> Enum.find(fn {iname, _} -> iname == name end) do
                  {_, input_pid} -> input_pid
                  true -> nil
                end
    {:reply, input_pid, state}
  end

  def handle_call(:outputs, _from, %{outputs: outputs} = state) do
    {:reply, outputs, state}
  end

  def handle_call({:output, name}, _from, %{outputs: outputs} = state) do
    output_pid = case outputs |> Enum.find(fn {oname, _} -> oname == name end) do
                   {_, output_pid} -> output_pid
                   true -> nil
                 end
    {:reply, output_pid, state}
  end

  def handle_cast(:cleanup, %{inputs: inputs, outputs: outputs} = state) do
    Logger.info("midi cleanup")
    inputs |> Enum.map(&Input.stop/1)
    outputs |> Enum.map(&Output.stop/1)
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("midi terminate")
    Logger.info("midi reason #{inspect reason}")
    Logger.info("midi state #{inspect state}")
  end
end
