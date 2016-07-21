defmodule Blister.DSL do
  @moduledoc """
  This module is responsible for loading and saving Blister.Pack data.
  State is a tuple containing {pack, song, patch}.
  """

  alias Blister.{Pack, Connection, Song, Patch, MIDI, SongList}

  @import "import Blister.Pack, except: [start_link: 1, load: 1, save: 1, reload: 0]\n"

  def load(file) do
    code = File.read!(file)
    load_string(code, file)
  end

  def load_string(code, file \\ "<string>") do
    code = @import <> code
    # TODO handle parsing errors
    {setup, _} = Code.eval_string(code, [],
      aliases: [{C, Blister.Consts}, {P, Blister.Predicates}],
      file: file, line: 0)
    setup |> setup_to_pack
  end

  def save(_file, _pack) do
    # file |> File.write!(pack_to_setup(pack))
  end

  defp setup_to_pack(setup) do
    with {:ok, inputs} <- parse_inputs(Map.get(setup, :inputs, []), %{}),
         {:ok, outputs} <- parse_outputs(Map.get(setup, :outputs, []), %{}),
         {:ok, all_songs} <- parse_songs(Map.get(setup, :songs, []), inputs, outputs, []),
         {:ok, messages} <- parse_messages(Map.get(setup, :messages, []), %{}),
         {:ok, message_bindings} <- parse_message_keys(Map.get(setup, :message_keys, []), %{}),
         {:ok, triggers} <- parse_triggers(Map.get(setup, :triggers, []), %{}),
         {:ok, song_lists} <- parse_song_lists(Map.get(setup, :song_lists, []), all_songs, []),
    do: %Pack{inputs: inputs,
              outputs: outputs,
              messages: messages,
              message_bindings: message_bindings,
              triggers: triggers,
              all_songs: all_songs,
              song_lists: song_lists}
  end

  defp parse_inputs([], inputs), do: {:ok, inputs}
  defp parse_inputs([{port, sym}|t], inputs) do
    parse_inputs([{port, sym, port}|t], inputs)
  end
  defp parse_inputs([{port, sym, name}|t], inputs) do
    in_pid = MIDI.input(port)
    parse_inputs(t, inputs |> Map.put(sym, {name, in_pid}))
  end

  defp parse_outputs([], outputs), do: {:ok, outputs}
  defp parse_outputs([{port, sym, name}|t], outputs) do
    out_pid = MIDI.output(port)
    parse_outputs(t, outputs |> Map.put(sym, {name, out_pid}))
  end


  defp parse_messages([], messages), do: {:ok, messages}
  defp parse_messages([msg|t], messages) do
    {name, bytes} = msg
    parse_messages(t, messages |> Map.put(name, bytes))
  end

  defp parse_message_keys([], message_keys), do: {:ok, message_keys}
  defp parse_message_keys([msgkey|t], message_keys) do
    {key, name} = msgkey
    parse_message_keys(t, message_keys |> Map.put(key, name))
  end

  defp parse_triggers([], triggers), do: {:ok, triggers}
  defp parse_triggers([trig|t], triggers) do
    {sym, bytes, func} = trig
    existing = triggers |> Map.get(sym, [])
    parse_triggers(t, triggers |> Map.put(sym, [{bytes, func} | existing]))
  end

  defp parse_songs([], _, _, songs), do: {:ok, Enum.reverse(songs)}
  defp parse_songs([s|t], inputs, outputs, songs) do
    with {:ok, patches} <- parse_patches(Map.get(s, :patches, []), inputs, outputs, [])
    do
      song = %Song{name: s.name, patches: patches, notes: Map.get(s, :notes)}
      parse_songs(t, inputs, outputs, [song | songs])
    end
  end

  defp parse_song_lists([], _, song_lists), do: {:ok, Enum.reverse(song_lists)}
  defp parse_song_lists([slist|t], all_songs, song_lists) do
    songs =
      slist
      |> Map.get(:songs, [])
      |> Enum.map(fn name ->
           Enum.find(all_songs, fn song -> song.name == name end)
         end)
    song_list = %SongList{name: slist.name, songs: songs}
    parse_song_lists(t, all_songs, [song_list | song_lists])
  end

  defp parse_patches([], _, _, patches), do: {:ok, Enum.reverse(patches)}
  defp parse_patches([p|t], inputs, outputs, patches) do
    with {:ok, conns} <- get_any(p, [:connections, :conns], [])
                         |> parse_connections(inputs, outputs, [])
    do
      patch = %Patch{name: p.name,
                     connections: conns,
                     start_bytes: Map.get(p, :start_bytes),
                     stop_bytes: Map.get(p, :stop_bytes)}
      parse_patches(t, inputs, outputs, [patch | patches])
    end
  end

  defp parse_connections([], _, _, conns), do: {:ok, conns}
  defp parse_connections([c|t], inputs, outputs, conns) do
    parse_connections(t, inputs, outputs,
      [parse_connection(c, inputs, outputs) | conns])
  end

  defp parse_connection(c, inputs, outputs) do
    with {in_pid, in_chan, out_pid, out_chan} <- parse_connection_io(c.io, inputs, outputs),
         {bank_msb, bank_lsb} <- parse_bank(c),
    do: {:ok,
         %Connection{input_pid: in_pid,
                     input_chan: in_chan,
                     output_pid: out_pid,
                     output_chan: out_chan,
                     filter: get_any(c, [:filter, :f]),
                     zone: Map.get(c, :zone),
                     xpose: get_any(c, [:transpose, :xpose]),
                     bank_msb: bank_msb,
                     bank_lsb: bank_lsb,
                     pc_prog: get_any(c, [:pc, :prog, :program])}}
  end

  defp parse_connection_io(nil, _, _) do
    {nil, nil, nil, nil}
  end
  defp parse_connection_io({in_sym, out_sym, out_ch}, inputs, outputs)
  when is_atom(in_sym) and is_atom(out_sym) and is_integer(out_ch)
  do
    parse_connection_io({in_sym, nil, out_sym, out_ch}, inputs, outputs)
  end
  defp parse_connection_io({in_sym, in_ch_or_nil, out_sym, out_ch}, inputs, outputs)
  when is_atom(in_sym) and is_atom(out_sym) and is_integer(out_ch)
  do
    with {_, in_pid} when is_pid(in_pid) <- Map.get(inputs, in_sym),
         {_, out_pid} when is_pid(out_pid) <- Map.get(outputs, out_sym) do
      in_ch = if in_ch_or_nil, do: in_ch_or_nil-1, else: nil
      {in_pid, in_ch, out_pid, out_ch-1}
    else
      nil -> {:error, "can not find input #{in_sym} or output #{out_sym} for connection"}
    end
  end
  defp parse_connection_io(huh, _, _) do
    {:error, "malformed connection io: #{inspect huh}"}
  end

  defp parse_bank(%{bank: {_, _} = bank}), do: bank
  defp parse_bank(%{bank_msb: msb, bank_lsb: lsb}), do: {msb, lsb}
  defp parse_bank(%{bank_msb: msb}), do: {msb, nil}
  defp parse_bank(%{bank_lsb: lsb}), do: {nil, lsb}
  defp parse_bank(_), do: {nil, nil}

  defp get_any(m, keys, default \\ nil) do
    Enum.find_value(keys, fn k -> Map.get(m, k) end) || default
  end
end
