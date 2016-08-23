defmodule Blister.MIDI.MockDriverTest do
  use ExUnit.Case
  alias Blister.MIDI.MockDriver, as: MD
  require Logger

  setup do
    MD.clear
    on_exit fn -> MD.clear end
  end

  test "devices" do
    ds = MD.devices
    assert (ds.input |> Enum.map(&(&1.name))) == ["input 1", "input 2"]
    assert (ds.output |> Enum.map(&(&1.name))) == ["output 1", "output 2"]
  end

  test "logs sent messages" do
    {:ok, out} = MD.open(:output, "output 1")
    MD.write(out, {1, 2, 3})
    MD.write(out, [{4, 5, 6}, {7, 0, 0}])
    assert MD.sent_messages("output 1") == [{1, 2, 3}, {4, 5, 6}, {7, 0, 0}]
  end

  test "logs received messages" do
    {:ok, inp} = MD.open(:input, "input 1")
    MD.input(inp, {1, 2, 3})
    MD.input(inp, [{4, 5, 6}, {7, 0, 0}])
    assert MD.received_messages("input 1") == [{1, 2, 3}, {4, 5, 6}, {7, 0, 0}]
  end

  test "sends input to listeners" do
    {:ok, inp} = MD.open(:input, "input 1")
    MD.listen(inp, self())
    MD.input(inp, {1, 2, 3})
    MD.input(inp, [{4, 5, 6}, {7, 0, 0}])
    receive_or_flunk(inp, {1, 2, 3})
    receive_or_flunk(inp, [{4, 5, 6}, {7, 0, 0}])
  end

  defp receive_or_flunk(inp, msgs) do
    receive do
      {^inp, ^msgs} ->
        :ok
      msg ->
        flunk("received #{inspect msg}; expected message(s) #{inspect msgs}")
    after
      1000 ->
        flunk("error: did not receive expected message(s) #{inspect msgs}")
    end
  end
end
