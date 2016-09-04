defmodule Blister.Web do

  use Trot.Router
  alias Blister.{Pack, MIDI}
  require Logger

  def start_link do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def visited(endpoint) do
    Agent.update(__MODULE__, fn _ -> endpoint end)
  end

  def last_visited do
    Agent.get(__MODULE__, fn endpoint -> endpoint end)
  end

  def return_status(message \\ nil) do
    sl = Pack.song_list
    %{lists: Pack.song_lists |> Enum.map(fn sl -> sl.name end),
      list: sl.name,
      songs: sl.songs |> Enum.map(fn sl -> sl.name end),
      triggers: [],             # TODO
      song: song_map(Pack.song),
      patch: patch_map(Pack.patch),
      message: message}
  end

  defp song_map(nil), do: nil
  defp song_map(song) do
    %{name: song.name,
      patches: song.patches |> Enum.map(fn p -> p.name end)}
  end

  defp patch_map(nil), do: nil
  defp patch_map(patch) do
    %{name: patch.name,
      connections: patch.connections |> Enum.map(fn conn -> conn_map(conn) end)}
  end

  defp conn_map(conn) do
    %{input: conn.input.sym,
      input_chan: conn.input.chan,
      output: conn.output.sym,
      output_chan: conn.output.chan,
      prog: program_change_string(conn.bank_msb, conn.bank_lsb, conn.pc_prog),
      zone: (if conn.zone, do: inspect(conn.zone)),
      xpose: (if conn.xpose, do: inspect(conn.xpose)),
      filter: (if conn.filter, do: inspect(conn.filter))}
  end

  defp program_change_string(nil, nil, nil), do: ""
  defp program_change_string(nil, nil, pc), do: pc
  defp program_change_string(nil, lsb, nil), do: "[#{lsb}]"
  defp program_change_string(nil, lsb, pc), do: "[#{lsb}] #{pc}"
  defp program_change_string(msb, nil, nil), do: "[#{msb}]"
  defp program_change_string(msb, nil, pc), do: "[#{msb}] #{pc}"
  defp program_change_string(msb, lsb, nil), do: "[#{msb}-#{lsb}]"
  defp program_change_string(msb, lsb, pc), do: "[#{msb}-#{lsb}] #{pc}"

# ================================================================
# URL handlers
# ================================================================

  # not_found do
  #   path = request.env["REQUEST_PATH"]
  #   unless path == "/favicon.ico" do
  #     IO.puts "error: not_found called, request = #{request.inspect}" # DEBUG
  #     return_status(message: "No such URL: #{path}")
  #   end
  # end

  get "/status" do
    # Don't count as a visit
    return_status()
  end

  get "/next_patch" do
    Pack.next_patch()
    visited :next_patch
    return_status()
  end

  get "/prev_patch" do
    Pack.prev_patch()
    visited :prev_patch
    return_status()
  end

  get "/next_song" do
    Pack.next_song()
    visited :next_song
    return_status()
  end

  get "/prev_song" do
    Pack.prev_song()
    visited :prev_song
    return_status()
  end

  get "/next_song_list" do
    Pack.next_song_list()
    visited :next_song_list
    return_status()
  end

  get "/prev_song_list" do
    Pack.prev_song_list()
    visited :prev_song_list
    return_status()
  end

  # When panic is called it sends the "all notes off" controller message on
  # all 16 MIDI channels. When it is called a second time in a row, a note
  # off message is sent to every note on all MIDI channels.
  get "/panic" do
    last_visited_was_panic = last_visited() == :panic
    Logger.debug("panic, spamming all notes = #{last_visited_was_panic}")
    MIDI.panic(last_visited_was_panic)
    if last_visited_was_panic do
      visited :panic_second_time # next panic will not spam all notes
    else
      visited :panic
    end
    msg = if last_visited_was_panic do
      "Panic: sent note off to every note on all MIDI channels"
    else
      "Panic: sent note off message on all MIDI channels"
    end
    return_status(msg)
  end

  redirect "/", "/index.html"

  static "/js", "js"
  static "/", ""
end
