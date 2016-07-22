defmodule Blister do
  use Application
  require Logger
  alias Blister.MIDI
  alias Blister.GUI.{Text, Curses}

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
  defp run([commands]) do
    do_run(fn -> Text.set_commands(commands |> to_char_list) end)
  end
  defp run([]) do
    do_run
  end
  defp run(["test"]) do
    do_run()
  end

  defp do_run(gui_config_func \\ nil) do
    Logger.info("starting supervisor")

    driver_module = Application.fetch_env!(:blister, :midi_driver_module)
    gui_module = Application.fetch_env!(:blister, :gui_module)
    result = Blister.Supervisor.start_link(driver_module, gui_module)

    if gui_config_func do
      gui_config_func.()
    end
    Logger.debug("supervisor started result = #{inspect result}, calling start_command_loop")
    if gui_module do
      Blister.Controller.start_command_loop
      receive do
        :quit -> :ok            # never received, but keeps app running
      end
    end
    result
  end
end
