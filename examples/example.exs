input "IAC Driver Bus 1", mb: "midiboard"
input "Foo Port 0", ws_in: "WaveStation"

output "IAC Driver Bus 1", ws_out: "WaveStation"
output "Foo Port 1", kz: "K200R"
output "Foo Port 2", sj: "SuperJupiter"

# In this setup, output Foo Port 2 => SuperJupiter => MIDI thru => Drum
# machine. This lets me refer to the same output as both :sj and :drums.
# There's an equivalent alias_input command as well.
alias_output :sj, :drums

message "Tune Request", [C.tune_request]
message "Full Volume", (0..15)
  |> Enum.map(fn chan -> [C.controller + chan, C.cc_volume, 127] end)
  |> List.flatten

message_key :f1, "Tune Request"
message_key :f2, "Full Volume"

trigger :mb, [C.controller, C.cc_gen_purpose_5, 127], &Pack.next_patch/0
trigger :mb, [C.controller, C.cc_gen_purpose_6, 127], &Pack.prev_patch/0
trigger :mb, [C.controller, C.cc_gen_purpose_7, 127], &Pack.next_song/0
trigger :mb, [C.controller, C.cc_gen_purpose_8, 127], &Pack.prev_song/0
trigger :mb, [C.controller, 126, 127], (fn -> Pack.send_message("Tune Request") end)

song "First Song" do
  notes """
Notes about this song
can span multiple lines.
"""
  patch "First Song, First Patch" do
    start_bytes [C.tune_request]
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
  end
  patch "First Song, Second Patch"
end

song "Second Song" do
  patch "Second Song, First Patch" do
          connections: [
            %{io: {:mb, :sj, 4}, prog_chg: 22, zone: (76..127)},
            %{io: {:ws_in, :ws_out, 6},zone: (64..75), filter: fn _conn, bytes ->
            bytes    # no-op
          end}
          ]},
  end
  patch "Second Song, Second Patch"
end

song_list "Tonigt's Song List", [
  "First Song",
  "Second Song"
]
