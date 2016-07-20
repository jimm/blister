defmodule Blister do
  use Application
  require Logger

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
  defp run(["text"]) do
    do_run(Blister.GUI.Text)
  end
  defp run(["text", commands]) do
    do_run(Blister.GUI.Text, fn -> Blister.GUI.Text.set_commands(commands |> to_char_list) end)
  end
  defp run([]) do
    do_run(Blister.GIU.Curses)
  end

  defp do_run(gui_module, gui_config_func \\ nil) do
    Logger.info("starting supervisor")
    result = Blister.Supervisor.start_link(gui_module)
    if gui_config_func do
      gui_config_func.()
    end
    Logger.debug("supervisor started result = #{inspect result}, calling start_command_loop")
    Blister.Controller.start_command_loop
    receive do
      :quit -> :ok              # never received, but keeps app running
    end
    result
  end
end
