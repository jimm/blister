defmodule Blister.MIDI do
  use GenServer
  import Supervisor.Spec
  require Logger
  alias Blister.MIDI.{Input, Output}
  alias Blister.Consts, as: C

  # ================ Server ================

  def start_link(driver_module) do
    devices = driver_module.devices
    input_workers =
      devices.input  |> Enum.map(&(worker(Input, [driver_module, &1.name], id: make_ref())))
    output_workers =
      devices.output |> Enum.map(&(worker(Output, [driver_module, &1.name], id: make_ref())))
    children = input_workers ++ output_workers

    {:ok, sup} = Supervisor.start_link(children, strategy: :one_for_one)

    state = %{sup: sup}
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

  def panic(spam_every_note) do
    GenServer.call(__MODULE__, {:panic, spam_every_note})
  end

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
  end

  # ================ Handlers ================

  def handle_call(:inputs, _from, state) do
    {:reply, child_pids(state.sup, Input), state}
  end

  def handle_call({:input, name}, _from, state) do
    {:reply, child_pid(state.sup, Input, name), state}
  end

  def handle_call(:outputs, _from, state) do
    {:reply, child_pids(state.sup, Output), state}
  end

  def handle_call({:output, name}, _from, state) do
    {:reply, child_pid(state.sup, Output, name), state}
  end

  def handle_call({:panic, spam_every_note}, _from, state) do
    messages = if spam_every_note do
      C.midi_channels |> Enum.map(fn chan ->
        C.all_notes |> Enum.map(fn note ->
          {C.note_off(chan), note, 64}
        end)
      end)
      |> List.flatten
    else
      C.midi_channels |> Enum.map(fn chan ->
        {C.controller(chan), C.cm_all_notes_off, 0}
      end)
    end

    child_pids(state.sup, Output)
    |> Enum.map(fn pid -> Output.write(pid, messages) end)
    {:reply, :ok, state}
  end

  def handle_cast(:cleanup, state) do
    Logger.info("midi cleanup")

    Supervisor.which_children(state.sup)
    |> Enum.each(fn {_id, pid, _type, [module]} ->
      module.stop(pid)
    end)

    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("midi terminate")
    if state != :shutdown, do: Logger.info("midi reason #{inspect reason}")
  end

  # ================ Helpers ================

  defp child_pids(sup, mod) do
    Supervisor.which_children(sup)
    |> Enum.filter(fn {_id, _pid, _type, [module]} -> module == mod end)
    |> Enum.map(fn {_id, pid, _type, _modules} -> pid end)
  end

  defp child_pid(sup, mod, name) do
    pids =
      Supervisor.which_children(sup)
      |> Enum.filter(fn {_id, pid, _type, [module]} ->
        module == mod && mod.port_name(pid) == name
      end)
      |> Enum.map(fn {_id, pid, _type, _modules} -> pid end)
    case pids do
      [h|_] -> h
      _ -> nil
    end
  end
end
