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
    driver_module = get_and_init_midi_driver()
    if Keyword.get(parsed, :list) do
      list(driver_module)
    else
      do_run(load_file, driver_module)
    end
  end

  defp do_run("test", driver_module) do
    do_run(nil, driver_module)
  end
  defp do_run(load_file, driver_module) do
    Logger.info("starting supervisor")
    result = Blister.Supervisor.start_link(driver_module)
    if load_file do
      Blister.Pack.load(load_file)
    end

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
end
