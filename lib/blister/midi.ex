defmodule Blister.MIDI do
  use GenServer
  require Logger

  # ================ Server ================

  def start_link do
    devices = PortMidi.devices

    # A list of Blister.Output structs
    outputs = devices.output |> Enum.map(fn d ->
      Blister.Output.open(d.name)
    end)

    # A list of Blister.Input pids
    inputs = devices.input |> Enum.map(fn d ->
      {:ok, input} = Blister.Input.start(d.name, [])
      input
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
  Returns a list of Blister.Inputs pids.
  """
  def inputs do
    GenServer.call(__MODULE__, :inputs)
  end

  @doc """
  Returns a list of Blister.Output structs.
  """
  def outputs do
    GenServer.call(__MODULE__, :outputs)
  end

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
  end

  # ================ Handlers ================

  def handle_call(:inputs, _from, %{inputs: inputs} = state) do
    {:reply, inputs, state}
  end

  def handle_call(:outputs, _from, %{outputs: outputs} = state) do
    {:reply, outputs, state}
  end

  def handle_cast(:cleanup, %{inputs: inputs, outputs: outputs} = state) do
    Logger.info("midi cleanup")
    inputs |> Enum.map(&Blister.Input.stop/1)
    outputs |> Enum.map(&Blister.Output.close/1)
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("midi terminate")
    Logger.info("midi reason #{inspect reason}")
    Logger.info("midi state #{inspect state}")
  end
end
