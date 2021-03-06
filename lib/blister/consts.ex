# MIDI and Blister constants.
defmodule Blister.Consts do
  # Range covering all MIDI channels (1-based).
  def midi_channels, do: 1..16

  # Range covering all note numbers  (0-based).
  def all_notes, do: 0..127

  #
  # Standard MIDI File meta event defs.
  #
  def meta_event, do: 0xFF
  def meta_seq_num, do: 0x00
  def meta_text, do: 0x01
  def meta_copyright, do: 0x02
  def meta_seq_name, do: 0x03
  def meta_instrument, do: 0x04
  def meta_lyric, do: 0x05
  def meta_marker, do: 0x06
  def meta_cue, do: 0x07
  def meta_midi_chan_prefix, do: 0x20
  def meta_track_end, do: 0x2F
  def meta_set_tempo, do: 0x51
  def meta_smpte, do: 0x54
  def meta_time_sig, do: 0x58
  def meta_patch_sig, do: 0x59
  def meta_seq_specif, do: 0x7F

  #
  # Channel messages. All channels are 1-based. Default channel is 1.
  #

  # Note, val
  def note_off(chan \\ 1), do: 0x80 + chan - 1

  # Note, val
  def note_on(chan \\ 1), do: 0x90 + chan - 1

  # Note, val
  def poly_pressure(chan \\ 1), do: 0xA0 + chan - 1

  # Controller #, val
  def controller(chan \\ 1), do: 0xB0 + chan - 1

  # Program number
  def program_change(chan \\ 1), do: 0xC0 + chan - 1

  # Channel pressure
  def channel_pressure(chan \\ 1), do: 0xD0 + chan - 1

  # LSB, MSB
  def pitch_bend(chan \\ 1), do: 0xE0 + chan - 1

  #
  # System common messages
  #

  # System exclusive start
  def sysex, do: 0xF0

  # Beats from top: LSB/MSB 6 ticks = 1 beat
  def song_pointer, do: 0xF2

  # Val = number of song
  def song_select, do: 0xF3

  # Tune request
  def tune_request, do: 0xF6

  # End of system exclusive
  def eox, do: 0xF7

  #
  # System realtime messages
  #

  # MIDI clock (24 per quarter note)
  def clock, do: 0xF8

  # Sequence start
  def start, do: 0xFA

  # Sequence continue
  def continue, do: 0xFB

  # Sequence stop
  def stop, do: 0xFC

  # Active sensing (sent every 300 ms when nothing else being sent)
  def active_sense, do: 0xFE

  # System reset
  def system_reset, do: 0xFF

  #
  # Controller numbers
  # = 0 - 31 = continuous, MSB
  # = 32 - 63 = continuous, LSB
  # = 64 - 97 = momentary switches
  #
  def c_bank_select, do: 0
  def cc_bank_select_msb, do: 0
  def cc_mod_wheel, do: 1
  def cc_mod_wheel_msb, do: 1
  def cc_breath_controller, do: 2
  def cc_breath_controller_msb, do: 2
  def cc_foot_controller, do: 4
  def cc_foot_controller_msb, do: 4
  def cc_portamento_time, do: 5
  def cc_portamento_time_msb, do: 5
  def cc_data_entry, do: 6
  def cc_data_entry_msb, do: 6
  def cc_volume, do: 7
  def cc_volume_msb, do: 7
  def cc_balance, do: 8
  def cc_balance_msb, do: 8
  def cc_pan, do: 10
  def cc_pan_msb, do: 10
  def cc_expression_controller, do: 11
  def cc_expression_controller_msb, do: 11
  def cc_gen_purpose_1, do: 16
  def cc_gen_purpose_1_msb, do: 16
  def cc_gen_purpose_2, do: 17
  def cc_gen_purpose_2_msb, do: 17
  def cc_gen_purpose_3, do: 18
  def cc_gen_purpose_3_msb, do: 18
  def cc_gen_purpose_4, do: 19
  def cc_gen_purpose_4_msb, do: 19

  #
  # [32 - 63] are LSB for [0 - 31]
  #
  def cc_bank_select_lsb, do: 32
  def cc_mod_wheel_lsb, do: 33
  def cc_breath_controller_lsb, do: 34
  def cc_foot_controller_lsb, do: 36
  def cc_portamento_time_lsb, do: 37
  def cc_data_entry_lsb, do: 38
  def cc_volume_lsb, do: 39
  def cc_balance_lsb, do: 40
  def cc_pan_lsb, do: 42
  def cc_expression_controller_lsb, do: 43
  def cc_gen_purpose_1_lsb, do: 48
  def cc_gen_purpose_2_lsb, do: 49
  def cc_gen_purpose_3_lsb, do: 50
  def cc_gen_purpose_4_lsb, do: 51

  #
  # Momentary switches:
  #
  def cc_sustain, do: 64
  def cc_portamento, do: 65
  def cc_sustenuto, do: 66
  def cc_soft_pedal, do: 67
  def cc_hold_2, do: 69
  def cc_gen_purpose_5, do: 50
  def cc_gen_purpose_6, do: 51
  def cc_gen_purpose_7, do: 52
  def cc_gen_purpose_8, do: 53
  def cc_ext_effects_depth, do: 91
  def cc_tremelo_depth, do: 92
  def cc_chorus_depth, do: 93
  def cc_detune_depth, do: 94
  def cc_phaser_depth, do: 95
  def cc_data_increment, do: 96
  def cc_data_decrement, do: 97
  def cc_nreg_param_lsb, do: 98
  def cc_nreg_param_msb, do: 99
  def cc_reg_param_lsb, do: 100
  def cc_reg_param_msb, do: 101

  #
  # Channel mode message values
  #
  # Val 0 == off, 0x7f == on
  def cm_reset_all_controllers, do: 0x79
  def cm_local_control, do: 0x7A
  # val must be 0
  def cm_all_notes_off, do: 0x7B
  # val must be 0
  def cm_omni_mode_off, do: 0x7C
  # val must be 0
  def cm_omni_mode_on, do: 0x7D
  # val = # chans
  def cm_mono_mode_on, do: 0x7E
  # val must be 0
  def cm_poly_mode_on, do: 0x7F

  @controller_names [
    "Bank Select (MSB)",
    "Modulation (MSB)",
    "Breath Control (MSB)",
    "3 (MSB)",
    "Foot Controller (MSB)",
    "Portamento Time (MSB)",
    "Data Entry (MSB)",
    "Volume (MSB)",
    "Balance (MSB)",
    "9 (MSB)",
    "Pan (MSB)",
    "Expression Control (MSB)",
    "12 (MSB)",
    "13 (MSB)",
    "14 (MSB)",
    "15 (MSB)",
    "General Controller 1 (MSB)",
    "General Controller 2 (MSB)",
    "General Controller 3 (MSB)",
    "General Controller 4 (MSB)",
    "20 (MSB)",
    "21 (MSB)",
    "22 (MSB)",
    "23 (MSB)",
    "24 (MSB)",
    "25 (MSB)",
    "26 (MSB)",
    "27 (MSB)",
    "28 (MSB)",
    "29 (MSB)",
    "30 (MSB)",
    "31 (MSB)",
    "Bank Select (LSB)",
    "Modulation (LSB)",
    "Breath Control (LSB)",
    "35 (LSB)",
    "Foot Controller (LSB)",
    "Portamento Time (LSB)",
    "Data Entry (LSB)",
    "Volume (LSB)",
    "Balance (LSB)",
    "41 (LSB)",
    "Pan (LSB)",
    "Expression Control (LSB)",
    "44 (LSB)",
    "45 (LSB)",
    "46 (LSB)",
    "47 (LSB)",
    "General Controller 1 (LSB)",
    "General Controller 2 (LSB)",
    "General Controller 3 (LSB)",
    "General Controller 4 (LSB)",
    "52 (LSB)",
    "53 (LSB)",
    "54 (LSB)",
    "55 (LSB)",
    "56 (LSB)",
    "57 (LSB)",
    "58 (LSB)",
    "59 (LSB)",
    "60 (LSB)",
    "61 (LSB)",
    "62 (LSB)",
    "63 (LSB)",
    "Sustain Pedal",
    "Portamento",
    "Sostenuto",
    "Soft Pedal",
    "68",
    "Hold 2",
    "70",
    "71",
    "72",
    "73",
    "74",
    "75",
    "76",
    "77",
    "78",
    "79",
    "General Controller 5",
    "Tempo Change",
    "General Controller 7",
    "General Controller 8",
    "84",
    "85",
    "86",
    "87",
    "88",
    "89",
    "90",
    "External Effects Depth",
    "Tremolo Depth",
    "Chorus Depth",
    "Detune (Celeste) Depth",
    "Phaser Depth",
    "Data Increment",
    "Data Decrement",
    "Non-Registered Param LSB",
    "Non-Registered Param MSB",
    "Registered Param LSB",
    "Registered Param MSB",
    "102",
    "103",
    "104",
    "105",
    "106",
    "107",
    "108",
    "109",
    "110",
    "111",
    "112",
    "113",
    "114",
    "115",
    "116",
    "117",
    "118",
    "119",
    "120",
    "Reset All Controllers",
    "Local Control",
    "All Notes Off",
    "Omni Mode Off",
    "Omni Mode On",
    "Mono Mode On",
    "Poly Mode On"
  ]

  def controller_names, do: @controller_names

  # General MIDI patch names
  @gm_patch_names [
    # Pianos
    "Acoustic Grand Piano",
    "Bright Acoustic Piano",
    "Electric Grand Piano",
    "Honky-tonk Piano",
    "Electric Piano 1",
    "Electric Piano 2",
    "Harpsichord",
    "Clavichord",

    # Tuned Idiophones
    "Celesta",
    "Glockenspiel",
    "Music Box",
    "Vibraphone",
    "Marimba",
    "Xylophone",
    "Tubular Bells",
    "Dulcimer",

    # Organs
    "Drawbar Organ",
    "Percussive Organ",
    "Rock Organ",
    "Church Organ",
    "Reed Organ",
    "Accordion",
    "Harmonica",
    "Tango Accordion",

    # Guitars
    "Acoustic Guitar (nylon)",
    "Acoustic Guitar (steel)",
    "Electric Guitar (jazz)",
    "Electric Guitar (clean)",
    "Electric Guitar (muted)",
    "Overdriven Guitar",
    "Distortion Guitar",
    "Guitar harmonics",

    # Basses
    "Acoustic Bass",
    "Electric Bass (finger)",
    "Electric Bass (pick)",
    "Fretless Bass",
    "Slap Bass 1",
    "Slap Bass 2",
    "Synth Bass 1",
    "Synth Bass 2",

    # Strings
    "Violin",
    "Viola",
    "Cello",
    "Contrabass",
    "Tremolo Strings",
    "Pizzicato Strings",
    "Orchestral Harp",
    "Timpani",

    # Ensemble strings and voices
    "String Ensemble 1",
    "String Ensemble 2",
    "SynthStrings 1",
    "SynthStrings 2",
    "Choir Aahs",
    "Voice Oohs",
    "Synth Voice",
    "Orchestra Hit",

    # Brass
    "Trumpet",
    "Trombone",
    "Tuba",
    "Muted Trumpet",
    "French Horn",
    "Brass Section",
    "SynthBrass 1",
    "SynthBrass 2",

    # Reeds
    # 64
    "Soprano Sax",
    "Alto Sax",
    "Tenor Sax",
    "Baritone Sax",
    "Oboe",
    "English Horn",
    "Bassoon",
    "Clarinet",

    # Pipes
    "Piccolo",
    "Flute",
    "Recorder",
    "Pan Flute",
    "Blown Bottle",
    "Shakuhachi",
    "Whistle",
    "Ocarina",

    # Synth Leads
    "Lead 1 (square)",
    "Lead 2 (sawtooth)",
    "Lead 3 (calliope)",
    "Lead 4 (chiff)",
    "Lead 5 (charang)",
    "Lead 6 (voice)",
    "Lead 7 (fifths)",
    "Lead 8 (bass + lead)",

    # Synth Pads
    "Pad 1 (new age)",
    "Pad 2 (warm)",
    "Pad 3 (polysynth)",
    "Pad 4 (choir)",
    "Pad 5 (bowed)",
    "Pad 6 (metallic)",
    "Pad 7 (halo)",
    "Pad 8 (sweep)",

    # Effects
    "FX 1 (rain)",
    "FX 2 (soundtrack)",
    "FX 3 (crystal)",
    "FX 4 (atmosphere)",
    "FX 5 (brightness)",
    "FX 6 (goblins)",
    "FX 7 (echoes)",
    "FX 8 (sci-fi)",

    # Ethnic
    "Sitar",
    "Banjo",
    "Shamisen",
    "Koto",
    "Kalimba",
    "Bag pipe",
    "Fiddle",
    "Shanai",

    # Percussion
    "Tinkle Bell",
    "Agogo",
    "Steel Drums",
    "Woodblock",
    "Taiko Drum",
    "Melodic Tom",
    "Synth Drum",
    "Reverse Cymbal",

    # Sound Effects
    "Guitar Fret Noise",
    "Breath Noise",
    "Seashore",
    "Bird Tweet",
    "Telephone Ring",
    "Helicopter",
    "Applause",
    "Gunshot"
  ]

  def gm_patch_names, do: @gm_patch_names

  # GM drum notes start at 35 (C), so subtrack gm_drum_note_lowest from your
  # note number before using this array.
  def gm_drum_note_lowest, do: 35

  # General MIDI drum channel note names.
  @gm_drum_note_names [
    # 35, C
    "Acoustic Bass Drum",
    # 36, C#
    "Bass Drum 1",
    # 37, D
    "Side Stick",
    # 38, D#
    "Acoustic Snare",
    # 39, E
    "Hand Clap",
    # 40, F
    "Electric Snare",
    # 41, F#
    "Low Floor Tom",
    # 42, G
    "Closed Hi Hat",
    # 43, G#
    "High Floor Tom",
    # 44, A
    "Pedal Hi-Hat",
    # 45, A#
    "Low Tom",
    # 46, B
    "Open Hi-Hat",
    # 47, C
    "Low-Mid Tom",
    # 48, C#
    "Hi Mid Tom",
    # 49, D
    "Crash Cymbal 1",
    # 50, D#
    "High Tom",
    # 51, E
    "Ride Cymbal 1",
    # 52, F
    "Chinese Cymbal",
    # 53, F#
    "Ride Bell",
    # 54, G
    "Tambourine",
    # 55, G#
    "Splash Cymbal",
    # 56, A
    "Cowbell",
    # 57, A#
    "Crash Cymbal 2",
    # 58, B
    "Vibraslap",
    # 59, C
    "Ride Cymbal 2",
    # 60, C#
    "Hi Bongo",
    # 61, D
    "Low Bongo",
    # 62, D#
    "Mute Hi Conga",
    # 63, E
    "Open Hi Conga",
    # 64, F
    "Low Conga",
    # 65, F#
    "High Timbale",
    # 66, G
    "Low Timbale",
    # 67, G#
    "High Agogo",
    # 68, A
    "Low Agogo",
    # 69, A#
    "Cabasa",
    # 70, B
    "Maracas",
    # 71, C
    "Short Whistle",
    # 72, C#
    "Long Whistle",
    # 73, D
    "Short Guiro",
    # 74, D#
    "Long Guiro",
    # 75, E
    "Claves",
    # 76, F
    "Hi Wood Block",
    # 77, F#
    "Low Wood Block",
    # 78, G
    "Mute Cuica",
    # 79, G#
    "Open Cuica",
    # 80, A
    "Mute Triangle",
    # 81, A#
    "Open Triangle"
  ]

  def gm_drum_note_names, do: @gm_drum_note_names
end
