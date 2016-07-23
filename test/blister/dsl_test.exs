defmodule Blister.DSLTest do
  use ExUnit.Case
  alias Blister.{DSL, Pack, MIDI}
  alias Blister.Consts, as: C

  @testfile "examples/test.exs"

  setup do
    {:ok, %{str: File.read!(@testfile),
            in1_pid: MIDI.input("input 1"),
            in2_pid: MIDI.input("input 2"),
            out1_pid: MIDI.output("output 1"),
            out2_pid: MIDI.output("output 2")}}
  end

  test "loads an empty setup" do
    assert DSL.load_string("%{}") == %Pack{}
  end

  test "loads inputs", context do
    pack = DSL.load_string(context[:str])
    assert pack.inputs == %{mb: {"midiboard", context[:in1_pid]},
                             ws_in: {"WaveStation", context[:in2_pid]}}
  end

  test "loads outputs", context do
    pack = DSL.load_string(context[:str])
    assert pack.outputs == %{ws_out: {"WaveStation", context[:out1_pid]},
                              sj: {"SuperJupiter", context[:out2_pid]},
                               drums: {"output 2", context[:out2_pid]}}
  end

  test "loads messages", context do
    pack = DSL.load_string(context[:str])
    msgs = pack.messages
    assert (msgs |> Map.keys |> length) == 2
    assert msgs["Tune Request"] == [{C.tune_request, 0, 0}]
    assert length(msgs["Full Volume"]) == 16
  end

  test "loads message keys", context do
    pack = DSL.load_string(context[:str])
    assert pack.message_bindings == %{f1: "Tune Request", f2: "Full Volume"}
  end

  test "loads triggers", context do
    pack = DSL.load_string(context[:str])
    ts = pack.triggers
    assert (ts |> Map.keys |> length) == 2
    assert length(ts[:mb]) == 4
    assert length(ts[:ws_in]) == 1
    [{msg, f}] = ts[:ws_in]
    assert msg == {C.tune_request, 0, 0}
    assert is_function(f)
  end
end
