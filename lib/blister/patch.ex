defmodule Blister.Patch do
  defstruct name: "Unnamed",
    connections: [],
    start_messages: [],
    stop_messages: [],
    running: false

  alias Blister.Connection

  def inputs(patch) do
    patch.connections |> Enum.map(&(&1.input)) |> Enum.uniq
  end

  def start(nil), do: nil
  def start(%__MODULE__{running: true}) do
    # already running
  end
  def start(patch) do
    patch.connections |> Enum.map(&Connection.start(&1, patch.start_messages))
  end

  def stop(nil), do: nil
  def stop(%__MODULE__{running: false}) do
    # not running
  end
  def stop(patch) do
    patch.connections |> Enum.map(&Connection.stop(&1, patch.stop_messages))
  end
end
