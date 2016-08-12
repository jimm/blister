defmodule Blister do
  use Application
  require Logger

  def start(_type, _args) do
    {parsed, args, invalid} =
      OptionParser.parse(System.argv,
        switches: [list: :boolean, text: :boolean, cmds: :string],
        aliases: [l: :list, t: :text, c: :cmds])
    load_file = case args do
                  [] -> nil
                  [f|_] -> f
                end
    if length(invalid) > 0 do
      usage(invalid)
    else
      run(parsed, load_file)
    end
  end

  defp run(parsed, load_file) do
    driver_module = get_and_init_midi_driver
    if Keyword.get(parsed, :list) do
      list(driver_module)
    else
      gui_module = get_and_init_gui_module(parsed)
      cmds = Keyword.get(parsed, :cmds)
      gui_config_func = if gui_module == Blister.GUI.Text && cmds do
        fn -> Blister.GUI.Text.set_commands(cmds |> to_char_list) end
      else
        nil
      end
      do_run(load_file, driver_module, gui_module, gui_config_func)
    end
  end

  defp do_run("test", driver_module, gui_module, gui_config_func) do
    do_run(nil, driver_module, gui_module, gui_config_func)
  end
  defp do_run(load_file, driver_module, gui_module, gui_config_func) do
    Logger.info("starting supervisor")
    result = Blister.Supervisor.start_link(driver_module, gui_module)
    if load_file do
      Blister.Controller.load_file(load_file)
    end

    if gui_config_func do
      gui_config_func.()
    end

    Logger.debug("calling start_command_loop")
    Blister.Controller.start_command_loop
    receive do
      :quit -> :ok              # never received, but keeps app running
    end
    result
  end

  defp list(driver_module) do
    %{input: inputs, output: outputs} = driver_module.devices
    f = fn d -> IO.puts "  #{d.name}" end
    IO.puts "Inputs:"
    inputs |> Enum.map(f)
    IO.puts "Outputs:"
    outputs |> Enum.map(f)
    :init.stop
    {:ok, self()}
  end

  defp usage(nil) do
    IO.puts """
    usage: blister [--list | --text [--cmds "..."]] [some_blister_file.exs]

    --list, -l   Outputs the list of connected MIDI devices and exits.
    --text, -t   Uses a text-only interface (no curses windows).
    --cmds, -c   "..." sends the characters in the string one by one to Blister.
                 Normally used only for develompent/debugging.
    """
  end
  defp usage(invalid) do
    IO.puts "error: #{invalid.inspect}"
    IO.puts ""
    usage(nil)
  end

  defp get_and_init_midi_driver do
    driver_module = Application.get_env(:blister, :midi_driver_module)
    if driver_module == Blister.MIDI.MockDriver do
      Blister.MIDI.MockDriver.start_link
    end
    driver_module
  end

  defp get_and_init_gui_module(options) do
    if Keyword.get(options, :text) do
      Blister.GUI.Text
    else
      Application.get_env(:blister, :gui_module)
    end
  end
end
