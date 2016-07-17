defmodule Blister.DSL do
  @moduledoc """
  This module is responsible for loading and saving Blister.Pack data.
  State is a tuple containing {pack, song, patch}.
  """

  alias Blister.{Pack, Connection, Song, Patch, MIDI}

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
    all_songs = parse_songs(setup.songs, [])
    %Pack{inputs: parse_inputs(setup.inputs, []),
          outputs: parse_outputs(setup.outputs, []),
          messages: parse_messages(setup.messages, []),
          message_bindings: parse_message_keys(setup.message_keys, %{}),
          triggers: parse_triggers(setup.triggers, []),
          all_songs: all_songs,
          song_lists: parse_song_lists(setup.song_lists, all_songs, [])}
  end

  def parse_inputs([], inputs), do: inputs
  def parse_inputs([{port, sym, name}|t], inputs) do
    # TODO
    input = nil
    parse_inputs(t, [input | inputs])
  end

  def parse_outputs([], outputs), do: outputs
  def parse_outputs([{port, sym, name}|t], outputs) do
    # TODO
    output = nil
    parse_outputs(t, [output | outputs])
  end

  def parse_messages([], messages), do: messages
  def parse_messages([msg|t], messages) do
    # TODO
    message = nil
    parse_messages(t, [message | messages])
  end

  def parse_message_keys([], message_keys), do: message_keys
  def parse_message_keys([msgkey|t], message_keys) do
    # TODO
    key = nil
    val = nil
    parse_message_keys(t, Map.put(message_keys, key, val))
  end

  def parse_triggers([], triggers), do: triggers
  def parse_triggers([trig|t], triggers) do
    # TODO
    trigger = nil
    parse_triggers(t, [trigger | triggers])
  end

  def parse_songs([], songs), do: Enum.reverse(songs)
  def parse_songs([s|t], songs) do
    # TODO
    song = nil
    parse_songs(t, [song | songs])
  end

  def parse_song_lists([], _, song_lists), do: Enum.reverse(song_lists)
  def parse_song_lists([slist|t], all_songs, song_lists) do
    # TODO
    song_list = nil
    parse_song_lists(t, all_songs, [song_list | song_lists])
  end






#   def message(name, bytes) do
#     Agent.update(__MODULE__, fn {pack, song, patch} ->
#       {%{pack | messages: Map.put(pack.messages, name, bytes)}, song, patch}
#     end)
#   end

#   def message_key(_key, _name) do
#   end

#   def trigger(_input, _bytes, _func) do
#   end

#   def song(name, patches) do
#     # Agent.update(__MODULE__, fn {pack, song, patch} ->
#     #   song = add_patch_to_song(song, patch)
#     #   all_songs = if song, do: [song | pack.all_songs], else: pack.all_songs
#     #   {%{pack | all_songs: all_songs}, %Song{name, ???}, nil}
#     # end)
#   end

#   def notes(notes) do
#     notes
#   end

#   def patch(name, contents) do
#     Agent.update(__MODULE__, fn {pack, song, patch} ->
#       song = add_patch_to_song(song, patch)
# # FIXME
#       {pack, song, %Patch{name: name}} # FIXME
#     end)
#   end

#   def start_bytes(bytes) do
#     Agent.update(__MODULE__, fn {pack, song, patch} ->
#       {pack, song, {%{patch | start_bytes: bytes}}}
#     end)
#   end

#   def stop_bytes(bytes) do
#     Agent.update(__MODULE__, fn {pack, song, patch} ->
#       {pack, song, {%{patch | stop_bytes: bytes}}}
#     end)
#   end

#   def connection(input, input_chan \\ nil, output, output_chan, opts) do
#     bank_msb = cond do
#       opts[:bank_msb] -> opts[:bank_msb]
#       {msb, _lsb} = opts[:bank] -> msb
#       true -> nil
#     end
#     bank_lsb = cond do
#       opts[:bank_lsb] -> opts[:bank_lsb]
#       {_msb, lsb} = opts[:bank] -> lsb
#       true -> nil
#     end
#     Agent.update(__MODULE__, fn {pack, song, patch} ->
#       conn = %Connection{input_pid: Pack.input_pid_from_sym(pack, input),
#                          input_chan: input_chan,
#                          output_pid: Pack.output_pid_from_sym(pack, output),
#                          output_chan: output_chan,
#                          filter: opts[:filter],
#                          zone: opts[:zone],
#                          xpose: opts[:xpose] || opts[:transpose],
#                          bank_msb: bank_msb,
#                          bank_lsb: bank_lsb,
#                          pc_prog: opts[:pc] || opts[:prog] || opts[:program]}
#       {pack, song, %{patch | connections: [conn | patch.connections]}}
#     end)
#   end

#   def conn(input, input_chan \\ nil, output, output_chan, opts) do
#     connection(input, input_chan, output, output_chan, opts)
#   end

#   def c(input, input_chan \\ nil, output, output_chan, opts) do
#     connection(input, input_chan, output, output_chan, opts)
#   end

#   defp add_patch_to_song(song, nil) do
#     song
#   end
#   defp add_patch_to_song(song, patch) do
#     %{song | patches: [patch | song.patches]}
#   end
end
