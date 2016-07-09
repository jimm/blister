defmodule Blister do
  use Application
  require Logger

  def start(_type, _args) do
    argv = System.argv
    if length(argv) > 0 && hd(argv) == "list" do
      list_devices
      {:ok, self}
    else
      run
    end
  end

  defp list_devices do
    %{input: inputs, output: outputs} = PortMidi.devices
    f = fn d -> IO.puts "  #{d.name}" end
    IO.puts "Inputs:"
    inputs |> Enum.map(f)
    IO.puts "Outputs:"
    outputs |> Enum.map(f)
  end

  defp run do
    Logger.info("starting supervisor")
    result = Blister.Supervisor.start_link()
    Logger.debug("supervisor started result = #{inspect result}, calling start_command_loop")
    Blister.Controller.start_command_loop
    receive do
      :quit -> :ok              # never received, but keeps app running
    end
    result
  end
end
