defmodule Blister do
  use Application
  require Logger
  alias Blister.MIDI

  def start(_type, _args) do
    run(System.argv)
  end

  defp run(["list"]) do
    %{input: inputs, output: outputs} = PortMidi.devices
    f = fn d -> IO.puts "  #{d.name}" end
    IO.puts "Inputs:"
    inputs |> Enum.map(f)
    IO.puts "Outputs:"
    outputs |> Enum.map(f)
    :init.stop
    {:ok, self}
  end
  defp run(["test"]) do
    Blister.MIDI.MockDriver.start_link
    do_run
  end
  defp run([commands]) do
    do_run(fn -> Blister.GUI.Text.set_commands(commands |> to_char_list) end)
  end
  defp run(_) do
    do_run
  end

  defp do_run(gui_config_func \\ nil)
  defp do_run(nil) do
    Logger.info("starting supervisor")
    driver_module = Application.get_env(:blister, :midi_driver_module)
    gui_module = Application.get_env(:blister, :gui_module)
    result = Blister.Supervisor.start_link(driver_module, gui_module)
    Logger.debug("supervisor started, result = #{inspect result}")
    result
  end
  defp do_run(gui_config_func) do
    result = do_run(nil)
    gui_config_func.()
    Logger.debug("calling start_command_loop")
    Blister.Controller.start_command_loop
    receive do
      :quit -> :ok              # never received, but keeps app running
    end
    result
  end
end
