defmodule Blister.DSLTest do
  use ExUnit.Case
  alias Blister.{DSL, Pack, MIDI, Connection}
  alias Blister.Consts, as: C

  @testfile "examples/test.exs"

  setup context do
    str = File.read!(@testfile)
    pack = if context[:noparse], do: nil, else: DSL.load_string(str)
    {:ok, %{str: str,
            pack: pack,
            in1_pid: MIDI.input("input 1"),
            in2_pid: MIDI.input("input 2"),
            out1_pid: MIDI.output("output 1"),
            out2_pid: MIDI.output("output 2")}}
  end

  @tag :noparse
  test "loads an empty setup" do
    assert DSL.load_string("%{}") == %Pack{}
  end

  test "loads inputs", context do
    assert context[:pack].inputs ==
      %{mb: {"midiboard", context[:in1_pid]},
        ws_in: {"WaveStation", context[:in2_pid]}}
  end

  test "loads outputs", context do
    assert context[:pack].outputs ==
      %{ws_out: {"WaveStation", context[:out1_pid]},
        sj: {"SuperJupiter", context[:out2_pid]},
        drums: {"output 2", context[:out2_pid]}}
  end

  test "loads messages", context do
    msgs = context[:pack].messages
    assert (msgs |> Map.keys |> length) == 2
    assert msgs["Tune Request"] == [{C.tune_request, 0, 0}]
    assert length(msgs["Full Volume"]) == 16
  end

  test "loads message keys", context do
    assert context[:pack].message_bindings == %{f1: "Tune Request", f2: "Full Volume"}
  end

  test "loads triggers", context do
    ts = context[:pack].triggers
    assert (ts |> Map.keys |> length) == 2
    assert length(ts[:mb]) == 4
    assert length(ts[:ws_in]) == 1
    [{msg, f}] = ts[:ws_in]
    assert msg == {C.tune_request, 0, 0}
    assert is_function(f)
  end

  test "loads songs", context do
    songs = context[:pack].all_songs
    [s1, s2] = songs
    assert ([s1.name, s2.name]) == ["First Song", "Second Song"]
    assert Regex.match?(~r{Notes about this song\ncan span multiple lines.\n},
      s1.notes)
  end

  test "loads patches", context do
    songs = context[:pack].all_songs
    [s1, s2] = songs
    assert length(s1.patches) == 2
    assert length(s2.patches) == 2
    patch_names =
      songs
      |> Enum.map(&(&1.patches |> Enum.map(fn p -> p.name end)))
      |> List.flatten
    assert patch_names == [
      "First Song, First Patch",
      "First Song, Second Patch",
      "Second Song, First Patch",
      "Second Song, Second Patch"
    ]
  end

  test "loads patch start messages", context do
    songs = context[:pack].all_songs
    start_messages =
      songs
      |> Enum.map(&(&1.patches |> Enum.map(fn p -> p.start_messages end)))
    assert start_messages == [[[{C.tune_request, 0, 0}], []], [[], []]]
  end

  test "loads patch stop messages", context do
    songs = context[:pack].all_songs

    stop_messages =
      songs
      |> Enum.map(&(&1.patches |> Enum.map(fn p -> p.stop_messages end)))
    assert stop_messages == [[[], []], [[{C.tune_request, 0, 0}], []]]
  end

  test "loads connections", context do
    song = context[:pack].all_songs |> hd
    patch = song.patches |> hd
    conns = patch.connections
    assert length(conns) == 3

    [c1, c2, c3] = conns
    input_io = %Blister.Connection.IO{sym: :mb, pid: context[:in1_pid], chan: nil}
    output_io = %Blister.Connection.IO{sym: :sj, pid: context[:out2_pid], chan: 1}
    assert c1 == %Connection{input: input_io,
                             output: output_io,
                             filter: nil,
                             zone: (64..75),
                             xpose: 12,
                             bank_msb: nil,
                             bank_lsb: nil,
                             pc_prog: 64}
    input_io = %Blister.Connection.IO{sym: :mb, pid: context[:in1_pid], chan: 9}
    output_io = %Blister.Connection.IO{sym: :drums, pid: context[:out2_pid], chan: 9}
    assert c2 == %Connection{input: input_io,
                             output: output_io,
                             filter: nil,
                             zone: (64..75),
                             xpose: 12,
                             bank_msb: 1,
                             bank_lsb: 23,
                             pc_prog: 2}
    f = c3.filter
    assert f != nil
    input_io = %Blister.Connection.IO{sym: :ws_in, pid: context[:in2_pid], chan: nil}
    output_io = %Blister.Connection.IO{sym: :ws_out, pid: context[:out1_pid], chan: 3}
    assert c3 == %Connection{input: input_io,
                             output: output_io,
                             filter: f,
                             zone: nil,
                             xpose: nil,
                             bank_msb: 2,
                             bank_lsb: nil,
                             pc_prog: 100}
  end

  test "filter functions work", context do
    song = context[:pack].all_songs |> hd
    patch = song.patches |> hd
    [_, _, c3] = patch.connections
    f = c3.filter
    assert f.(c3, {0, 0, 0}) == {0, 0, 0}
    assert f.(c3, {0x83, 64, 100}) == {0x83, 64, 99}
  end

  test "loads song lists", context do
    sls = context[:pack].song_lists
    sl_names = sls |> Enum.map(&(&1.name))
    assert sl_names == ["Tonight's Song List"]

    song_names = hd(sls).songs |> Enum.map(&(&1.name))
    assert song_names == ["First Song", "Second Song"]
  end
end
