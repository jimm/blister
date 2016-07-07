defmodule Blister.Output do
  defstruct [:name, :output]

  def open(name) do
    {:ok, out_pid} = PortMidi.open(:output, name)
    %Blister.Output{name: name, output: out_pid}
  end

  def write(%{output: output}, messages) do
    PortMidi.write(output, messages)
  end

  def close(%{output: output}) do
    PortMidi.close(:output, output)
  end
end
