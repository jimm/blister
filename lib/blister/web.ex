defmodule Blister.Web do

  use Trot.Router
  alias Blister.Pack
  require Logger

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
      bank_msb: inspect(conn.bank_msb || ""), # TODO draw in HTML
      bank_lsb: inspect(conn.bank_lsb || ""), # TODO draw in HTML
      pc: inspect(conn.pc_prog || ""),
      zone: inspect(conn.zone || ""),
      xpose: inspect(conn.xpose || ""),
      filter: inspect(conn.filter || "")}
  end

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
    return_status()
  end

  get "/next_patch" do
    Pack.next_patch()
    return_status()
  end

  get "/prev_patch" do
    Pack.prev_patch()
    return_status()
  end

  get "/next_song" do
    Pack.next_song()
    return_status()
  end

  get "/prev_song" do
    Pack.prev_song()
    return_status()
  end

  get "/panic" do
    # TODO when panic called twice in a row, call panic(true)
    # TODO write panic
    # Pack.panic()
    return_status()
  end

  redirect "/", "/index.html"

  static "/js", "js"
  static "/", ""
end
