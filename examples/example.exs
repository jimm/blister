%{
  inputs: [mb: "midiboard", ws_in: "WaveStation"],
  outputs: [{:ws_out, "WaveStation"}, {:kz, "K2000R"}, :sj],

  # In this setup, output 4 => SJ => MIDI thru => Drum machine. This lets me
  # refer to the same output as both :sj and :drums. There's an equivalent
  # alias_input command as well.
  alias_outputs: [sj: :drums],

  messages: [
    [name: "Tune Request", bytes: [C.tune_request]],
    [name: "Full Volume",
     bytes: (0..15)
       |> Enum.map(fn chan -> [C.controller + chan, C.cc_volume, 127] end)
       |> List.flatten
    ]
  ],

  message_keys: [
    f1: "Tune Request",
    f2: "Full Volume"
  ],

  triggers: [
    [input: :mb, bytes: [C.controller, C.cc_gen_purpose_5, 127], func: &Pack.next_patch/0],
    [input: :mb, bytes: [C.controller, C.cc_gen_purpose_6, 127], func: &Pack.prev_patch/0],
    [input: :mb, bytes: [C.controller, C.cc_gen_purpose_7, 127], func: &Pack.next_song/0],
    [input: :mb, bytes: [C.controller, C.cc_gen_purpose_8, 127], func: &Pack.prev_song/0],
    [input: :mb, bytes: [C.controller, 126, 127], func: (fn -> Pack.send_message("Tune Request") end)]
  ],

  songs: [
    %{name: "First Song",
      notes: """
  C
These are the words
          F            C
They are very clever words
     Ab mi
And deep
        G7
Oh, so deep

        C         C/B
This chorus does not
 C7/Bb     Ami
Refer to itself
        F
Don't think too hard, or
       G7
Your head
Will
  C
Explode
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
          ]},
        %{name: "Second Song, Second Patch"}
      ]}
  ],

  song_lists: [
    %{name: "Tonight's Song List",
      songs: ["First Song", "Second Song"]}
  ]
}
