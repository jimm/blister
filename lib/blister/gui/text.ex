defmodule Blister.GUI.Text do
  @behaviour Blister.GUI

  require Logger
  alias Blister.Pack

  # ================ Server ================

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Logger.info("text gui init")
    Process.flag(:trap_exit, true)
    {:ok, []}
  end

  # ================ API ================

  def set_commands(chars), do: GenServer.call(__MODULE__, {:set_commands, chars})

  def update do
    IO.puts "Song lists:"
    Pack.song_lists |> Enum.map(&(IO.puts "  #{&1.name}"))

    sl = Pack.song_list || %Blister.SongList{}
    IO.puts "Song list \"#{sl.name}\":"
    sl.songs |> Enum.map(&(IO.puts "  #{&1.name}"))

    IO.puts "Current Song: #{if Pack.song, do: Pack.song.name, else: "<none>"}"
    IO.puts "Current Patch: #{if Pack.patch, do: Pack.patch.name, else: "<none>"}"

    :ok
  end

  def help(file) do
    file |> File.read! |> IO.puts
    :ok
  end

  def getch, do: GenServer.call(__MODULE__, :getch)

  def prompt(title, prompt, default) do
    Logger.debug "prompt"
    gets_prompt = title <> case default do
                             nil -> ""
                             _ -> " (#{default})"
                           end
    Logger.debug "prompt = #{gets_prompt}"
    str = IO.gets("#{gets_prompt}: ") |> String.trim
    case str do
      "" -> nil
      _ -> {:ok, str}
    end
  end

  def cleanup do
    :ok
  end

  # ================ Handlers ================

  def handle_call({:set_commands, chars}, _from, _) do
    {:reply, :ok, chars}
  end

  def handle_call(:getch, _from, [ch | commands]) do
    # Logger.info("text gui returning #{[ch] |> to_string} from getch")
    ch = IO.gets("command: ") |> to_char_list |> hd
    {:reply, ch, commands}
  end

  def terminate(_reason, _state) do
    Logger.info("text gui terminate")
  end
end
