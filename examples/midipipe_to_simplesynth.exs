%{inputs: [
    {"MidiPipe Output 1", :mp, "MidiPipe"}
  ],
  outputs: [
    {"SimpleSynth virtual input", :ss, "SimpleSynth"},
  ],
  messages: [
    {"Tune Request", {C.tune_request}},
    {"Full Volume", C.midi_channels
      |> Enum.map(fn chan -> {C.controller(chan), C.cc_volume, 127} end)
      |> List.flatten}
  ],
  message_keys: %{f1: "Tune Request",
                  f2: "Full Volume"},
  triggers: [
    # All on MIDI channel 1
    {:mp, {C.controller, C.cc_gen_purpose_5, 127}, &Pack.next_patch/0},
    {:mp, {C.controller, C.cc_gen_purpose_6, 127}, &Pack.prev_patch/0},
    {:mp, {C.controller, C.cc_gen_purpose_7, 127}, &Pack.next_song/0},
    {:mp, {C.controller, C.cc_gen_purpose_8, 127}, &Pack.prev_song/0},
    {:mp, {C.controller, 126, 127}, fn -> Pack.send_message("Tune Request") end}
  ],
  songs: [
    %{name: "First Song",
      notes: """
      Notes about this song
      can span multiple lines.
      """,
      patches: [
        %{name: "First Song, First Patch",
          start_bytes: [C.tune_request],
          connections: [
            %{io: {:mp, :ss, 1},
              prog_chg: 64, zone: (64..75), xpose: 0},
          ]},
        %{name: "First Song, Second Patch"}
      ]},

    %{name: "Second Song",
      patches: [
        %{name: "Second Song, First Patch",
          connections: [
            %{io: {:mp, :ss, 1},
              prog_chg: 63, zone: (64..75), xpose: 12},
          ]}]},
    %{name: "Second Song, Second Patch"}],
  song_lists: [
    %{name: "Tonight's Song List",
      songs: [
        "First Song",
        "Second Song"
      ]}]}
