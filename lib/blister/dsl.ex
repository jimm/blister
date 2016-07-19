defmodule Blister.DSL do
  @moduledoc """
  This module is responsible for loading and saving Blister.Pack data.
  State is a tuple containing {pack, song, patch}.
  """

  alias Blister.{Pack, Connection, Song, Patch, MIDI, SongList}

  def load(file) do
    code = "import #{__MODULE__}\n" <> File.read!(file)
    Agent.start_link(fn -> {%Pack{}, nil, nil} end, name: __MODULE__)
    # TODO handle parsing errors
    {setup, _} = Code.eval_string(code, [],
      aliases: [{C, Blister.Consts}, {P, Blister.Pack}],
      file: file, line: 0)
    setup |> setup_to_pack
  end

  def save(_file, _pack) do
    # file |> File.write!(pack_to_setup(pack))
  end

  def setup_to_pack(setup) do
    inputs = parse_inputs(setup.inputs, %{})
    outputs = parse_outputs(setup.outputs, %{})
    all_songs = parse_songs(setup.songs, inputs, outputs, [])
    %Pack{inputs: inputs,
          outputs: outputs,
          messages: parse_messages(setup.messages, []),
          message_bindings: parse_message_keys(setup.message_keys, %{}),
          triggers: parse_triggers(setup.triggers, []),
          all_songs: all_songs,
          song_lists: parse_song_lists(setup.song_lists, all_songs, [])}
  end

  def parse_inputs([], inputs), do: inputs
  def parse_inputs([{port, sym}|t], inputs) do
    parse_inputs([{port, sym, port}|t], inputs)
  end
  def parse_inputs([{port, sym, name}|t], inputs) do
    in_pid = MIDI.input(port)
    parse_inputs(t, inputs |> Map.put(sym, {name, in_pid}))
  end

  def parse_outputs([], outputs), do: outputs
  def parse_outputs([{port, sym, name}|t], outputs) do
    out_pid = MIDI.output(port)
    parse_outputs(t, outputs |> Map.put(sym, {name, out_pid}))
  end

  def parse_messages([], messages), do: messages
  def parse_messages([msg|t], messages) do
    {name, bytes} = msg
    parse_messages(t, messages |> Map.put(name, bytes))
  end

  def parse_message_keys([], message_keys), do: message_keys
  def parse_message_keys([msgkey|t], message_keys) do
    {key, name} = msgkey
    parse_message_keys(t, message_keys |> Map.put(key, name))
  end

  def parse_triggers([], triggers), do: triggers
  def parse_triggers([trig|t], triggers) do
    {sym, bytes, func} = trig
    existing = triggers |> Map.get(sym, [])
    parse_triggers(t, triggers |> Map.put(sym, [{bytes, func} | existing]))
  end

  def parse_songs([], _, _, songs), do: Enum.reverse(songs)
  def parse_songs([s|t], inputs, outputs, songs) do
    parse_songs(t, inputs, outputs,
      [%Song{name: s.name,
             patches: parse_patches(Map.get(s, :patches, []), inputs, outputs, []),
             notes: Map.get(s, :notes)}
       | songs])
  end

  def parse_song_lists([], _, song_lists), do: Enum.reverse(song_lists)
  def parse_song_lists([slist|t], all_songs, song_lists) do
    songs =
      slist
      |> Map.get(:songs, [])
      |> Enum.map(fn name ->
           Enum.find(all_songs, fn song -> song.name == name end)
         end)
    song_list = %SongList{name: slist.name, songs: songs}
    parse_song_lists(t, all_songs, [song_list | song_lists])
  end

  def parse_patches([], _, _, patches), do: Enum.reverse(patches)
  def parse_patches([p|t], inputs, outputs, patches) do
    conns = get_any(p, [:connections, :conns], [])
      |> parse_connections(inputs, outputs, [])
    patch = %Patch{name: p.name,
                   connections: conns,
                   start_bytes: Map.get(p, :start_bytes),
                   stop_bytes: Map.get(p, :stop_bytes)}
    parse_patches(t, inputs, outputs, [patch | patches])
  end

  def parse_connections([], _, _, conns), do: conns
  def parse_connections([c|t], inputs, outputs, conns) do
    parse_connections(t, inputs, outputs,
      [parse_connection(c, inputs, outputs) | conns])
  end

  def parse_connection(c, inputs, outputs) do
    {in_pid, in_chan, out_pid, out_chan} =
      parse_connection_io(c.io, inputs, outputs)

    {bank_msb, bank_lsb} = Map.get(c, :bank, {Map.get(c, :bank_msb),
                                              Map.get(c, :bank_lsb)})
    %Connection{input_pid: in_pid,
                input_chan: in_chan,
                output_pid: out_pid,
                output_chan: out_chan,
                filter: get_any(c, [:filter, :f]),
                zone: Map.get(c, :zone),
                xpose: get_any(c, [:transpose, :xpose]),
                bank_msb: bank_msb,
                bank_lsb: bank_lsb,
                pc_prog: get_any(c, [:pc, :prog, :program])}
  end

  def parse_connection_io({in_sym, out_sym, out_chan}, inputs, outputs) do
    parse_connection_io({in_sym, nil, out_sym, out_chan}, inputs, outputs)
  end
  def parse_connection_io({in_sym, in_chan, out_sym, out_chan}, inputs, outputs) do
    {_, in_pid} = Map.get(inputs, in_sym)
    {_, out_pid} = Map.get(outputs, out_sym)
    {in_pid, in_chan, out_pid, out_chan}
  end

  def get_any(m, keys, default \\ nil) do
    Enum.find_value(keys, fn k -> Map.get(m, k) end) || default
  end
end
