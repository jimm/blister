defmodule Blister.Pack do
  @moduledoc """
  Holds all state related to a single Blister setup: all songs and patches,
  what file was loaded, etc.
  """

  defstruct [
    :inputs, :outputs, :all_songs, :song_lists, :messages,
    :message_bindings, :triggers, :code_bindings, :use_midi, :gui,
    :loaded_file, :cursor
  ]

  require Logger
  alias Blister.{Cursor, SongList}

  def start_link do
    Logger.info("pack init")
    Agent.start_link(
      fn ->
        pack = %__MODULE__{inputs: [], outputs: [], all_songs: [], song_lists: [],
                           messages: [], message_bindings: %{}, code_bindings: %{},
                           use_midi: true, loaded_file: nil}
        cursor = %Cursor{} |> Cursor.init(pack)
        %{pack | cursor: cursor}
      end,
      name: __MODULE__)
  end

  def inputs,           do: Agent.get(__MODULE__, fn pack -> pack.inputs end)
  def outputs,          do: Agent.get(__MODULE__, fn pack -> pack.outputs end)
  def all_songs,        do: Agent.get(__MODULE__, fn pack -> pack.all_songs end)
  def song_lists,       do: Agent.get(__MODULE__, fn pack -> pack.song_lists end)
  def messages,         do: Agent.get(__MODULE__, fn pack -> pack.messages end)
  def message_bindings, do: Agent.get(__MODULE__, fn pack -> pack.message_bindings end)
  def code_bindings,    do: Agent.get(__MODULE__, fn pack -> pack.code_bindings end)
  def use_midi?,        do: Agent.get(__MODULE__, fn pack -> pack.use_midi end)
  def gui,              do: Agent.get(__MODULE__, fn pack -> pack.gui end)
  def loaded_file,      do: Agent.get(__MODULE__, fn pack -> pack.loaded_file end)
  def cursor,           do: Agent.get(__MODULE__, fn pack -> pack.cursor end)

  def song_list, do: Agent.get(__MODULE__, fn pack -> pack.cursor.song_list end)
  def song,      do: Agent.get(__MODULE__, fn pack -> pack.cursor.song end)
  def patch,     do: Agent.get(__MODULE__, fn pack -> pack.cursor.patch end)

  def next_patch do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.next_patch(pack)}
    end)
  end
  def prev_patch do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.prev_patch(pack)}
    end)
  end
  def next_song do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.next_song(pack)}
    end)
  end
  def prev_song do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.prev_song(pack)}
    end)
  end

  def add_song(song) do
    list = all_songs
      |> SongList.add_song(song)
      |> SongList.sort_by_name
    Agent.update(__MODULE__, fn pack -> %{pack | all_songs: list} end)
  end

  def send_message(_name) do
    # TODO
  end

  def load(file) do
    Logger.debug("load file #{file}")
    setup =
      file
      |> File.read!
      |> Code.eval_string([], aliases: [{C, Blister.Consts}], file: file, line: 0)
    Agent.update(__MODULE__, fn pack -> load_setup(pack, setup) end)
  end

  def save(_file) do
    # TODO
  end

  def reload do
    file = Agent.get(__MODULE__, fn pack -> pack.loaded_file end)
    if file != nil do
      load(file)
    end
  end

  # TODO all accessors: add/remove song, song list, message, bindings, etc.

  def bind_message(_name, _key) do
  end

  def bind_code(_code_key) do
  end

  defp load_setup(pack, _setup) do
    # TODO
    %{pack |
      cursor: pack.cursor |> Cursor.init(pack)}
  end
end
