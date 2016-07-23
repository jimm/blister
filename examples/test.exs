%{inputs: [
    {"input 1", :mb, "midiboard"},
    {"input 2", :ws_in, "WaveStation"}
  ],
  outputs: [
    {"output 1", :ws_out, "WaveStation"},
    # In this setup, output 2 => SuperJupiter => MIDI thru => Drum
    # machine.
    {"output 2", :sj, "SuperJupiter"},
    {"output 2", :drums}        # default name "output 2"
  ],
  messages: [
    {"Tune Request", {C.tune_request}},
    {"Full Volume", (0..15)
      |> Enum.map(fn chan -> {C.controller + chan, C.cc_volume, 127} end)}
  ],
  message_keys: %{f1: "Tune Request",
                  f2: "Full Volume"},
  triggers: [
    {:mb, {C.controller, C.cc_gen_purpose_5, 127}, &Pack.next_patch/0},
    {:mb, {C.controller, C.cc_gen_purpose_6, 127}, &Pack.prev_patch/0},
    {:mb, {C.controller, C.cc_gen_purpose_7, 127}, &Pack.next_song/0},
    {:mb, {C.controller, C.cc_gen_purpose_8, 127}, &Pack.prev_song/0},
    {:ws_in, {C.tune_request}, fn ->
      Pack.send_message("Tune Request")
      Pack.send_message("Full Volume")
    end}
  ],
  songs: [
    %{name: "First Song",
      notes: """
      Notes about this song
      can span multiple lines.
      """,
      patches: [
        %{name: "First Song, First Patch",
          start_messages: [{C.tune_request}],
          connections: [
            %{io: {:mb, :sj, 2},
              prog_chg: 64, zone: (64..75), transpose: 12},
            %{io: {:mb, 10, :drums, 10},
              bank: {1, 23}, prog_chg: 2, zone: (64..75), xpose: 12},
            %{io: {:ws_in, :ws_out, 4},
              bank_msb: 2, program: 100,
              filter: fn _conn, {b0, b1, b2} = msg ->
                if P.note_off?(msg) do
                  {b0, b1, max(0, b2-1)} # decrease velocity by 1
                else
                  msg
                end
              end}
          ]},
        %{name: "First Song, Second Patch"}
      ]},

    %{name: "Second Song",
      patches: [
        %{name: "Second Song, First Patch",
          stop: [{C.tune_request}], # shorthand for stop_messages
          conns: [
            %{io: {:mb, :sj, 4}, prog_chg: 22, zone: (76..127)},
            %{io: {:ws_in, :ws_out, 6},zone: (64..75),
              filter: fn _conn, msg -> msg end} # no-op
          ]},
        %{name: "Second Song, Second Patch"}]}],
  song_lists: [
    %{name: "Tonight's Song List",
      songs: [
        "First Song",
        "Second Song"
      ]}]}
