defmodule Blister.MIDI do
  use GenServer
  import Supervisor.Spec
  require Logger
  alias Blister.MIDI.{Input, Output}

  # ================ Server ================

  def start_link do
    devices = PortMidi.devices
    output_workers =
      devices.output |> Enum.map(&(worker(Output, [&1.name])))
    input_workers =
      devices.input  |> Enum.map(&(worker(Input, [&1.name])))
    children = output_workers ++ input_workers

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

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
  end

  # ================ Handlers ================

  def handle_call(:inputs, _from, %{sup: sup} = state) do
    {:reply, child_pids(sup, Input), state}
  end

  def handle_call({:input, name}, _from, %{sup: sup} = state) do
    {:reply, child_pid(sup, Input, name), state}
  end

  def handle_call(:outputs, _from, %{sup: sup} = state) do
    {:reply, child_pids(sup, Output), state}
  end

  def handle_call({:output, name}, _from, %{sup: sup} = state) do
    {:reply, child_pid(sup, Output, name), state}
  end

  def handle_cast(:cleanup, %{sup: sup} = state) do
    Logger.info("midi cleanup")

    {in_kids, out_kids} =
      Supervisor.which_children(sup)
      |> Enum.partition(fn {_id, _pid, _type, [module]} -> module == Input end)

    in_kids  |> Enum.each(fn {_id, pid, _type, _modules} ->  Input.stop(pid) end)
    out_kids |> Enum.each(fn {_id, pid, _type, _modules} -> Output.stop(pid) end)

    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("midi terminate")
    Logger.info("midi reason #{inspect reason}")
    Logger.info("midi state #{inspect state}")
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
