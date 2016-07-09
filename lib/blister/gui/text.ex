defmodule Blister.GUI.Text do
  @behaviour Blister.GUI

  require Logger
  alias Blister.Pack

  # ================ Server ================

  def start_link do
    Logger.info("text gui init")
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.info("curses gui init")
    Process.flag(:trap_exit, true)
    {:ok, []}
  end

  # ================ API ================

  def update do
    IO.puts "Song list names:"
    Pack.song_lists |> Enum.map(&(IO.puts "  #{&1.name}"))

    sl = Pack.song_list || %Blister.SongList{}
    IO.puts "Song list \"#{sl.name}\":"
    sl.songs |> Enum.map(&(IO.puts "  #{&1.name}"))

    IO.puts "Current Song: #{if Pack.song, do: Pack.song.name, else: "<none>"}"
    IO.puts "Current Patch: #{if Pack.patch, do: Pack.patch.name, else: "<none>"}"

    :ok
  end

  def help(file) do
    file |> File.read! |> String.split("\n") |> IO.puts
    :ok
  end

  def getch do
    (IO.gets "command: ") |> to_char_list |> hd
  end

  def cleanup do
    :ok
  end

  # ================ Handlers ================

  def terminate(_reason, _state) do
    Logger.info("text gui terminate")
  end
end
