%{inputs: [
    {"IAC Driver Bus 1", :mb, "midiboard"},
    {"Foo Port 0", :ws_in, "WaveStation"}
  ],
  outputs: [
    {"IAC Driver Bus 1", :ws_out, "WaveStation"},
    {"Foo Port 1", :kz, "K200R"},
    # In this setup, output Foo Port 2 => SuperJupiter => MIDI thru => Drum
    # machine.
    {"Foo Port 2", :sj, "SuperJupiter"},
    {"Foo Port 2", :drums, "Drums"}
  ],
  messages: [
    {"Tune Request", [C.tune_request]},
    {"Full Volume", (0..15)
      |> Enum.map(fn chan -> [C.controller + chan, C.cc_volume, 127] end)
      |> List.flatten}
  ],
  message_keys: %{f1: "Tune Request",
                  f2: "Full Volume"},
  triggers: [
    {:mb, [C.controller, C.cc_gen_purpose_5, 127], &Pack.next_patch/0},
    {:mb, [C.controller, C.cc_gen_purpose_6, 127], &Pack.prev_patch/0},
    {:mb, [C.controller, C.cc_gen_purpose_7, 127], &Pack.next_song/0},
    {:mb, [C.controller, C.cc_gen_purpose_8, 127], &Pack.prev_song/0},
    {:mb, [C.controller, 126, 127], fn -> Pack.send_message("Tune Request") end}
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
            %{io: {:mb, :kz, 2},
              prog_chg: 64, zone: (64..75), xpose: 12},
            %{io: {:ws_in, :sj, 4},
              prog_chg: 100, zone: (64..75), filter: fn _conn, bytes ->
                if P.note_off?(bytes) do
                  # TODO bytes[2] -= 1 unless bytes[2] == 0 # decrease velocity by 1
                else
                  bytes
                end
              end}
          ]},
        %{name: "First Song, Second Patch"}
      ]},

    %{name: "Second Song",
      patches: [
        %{name: "Second Song, First Patch",
          connections: [
            %{io: {:mb, :sj, 4}, prog_chg: 22, zone: (76..127)},
            %{io: {:ws_in, :ws_out, 6},zone: (64..75), filter: fn _conn, bytes ->
            bytes    # no-op
          end}
          ]}]},
    %{name: "Second Song, Second Patch"}],
  song_lists: [
    %{name: "Tonight's Song List",
      songs: [
        "First Song",
        "Second Song"
      ]}]}
