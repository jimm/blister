defmodule Blister.Pack do

  defstruct [
    :inputs, :outputs, :all_songs, :song_lists, :messages,
    :message_bindings, :code_bindings, :use_midi, :gui, :loaded_file,
    :cursor
  ]

  @moduledoc """
  Holds all state related to a single Blister setup: all songs and patches,
  what file was loaded, etc.
  """

  require Logger
  alias Blister.{Cursor, SongList}

  def start_link do
    Logger.info("pack init")
    Agent.start_link(
      fn ->
        %__MODULE__{inputs: [], outputs: [], all_songs: [], song_lists: [],
                    messages: [], message_bindings: %{}, code_bindings: %{},
                    use_midi: true, loaded_file: nil, cursor: %Cursor{}}
      end,
      name: __MODULE__)
  end

  def cursor,           do: Agent.get(__MODULE__, fn pack -> pack.cursor end)
  def inputs,           do: Agent.get(__MODULE__, fn pack -> pack.inputs end)
  def outputs,          do: Agent.get(__MODULE__, fn pack -> pack.outputs end)
  def all_songs,        do: Agent.get(__MODULE__, fn pack -> pack.all_songs end)
  def song_lists,       do: Agent.get(__MODULE__, fn pack -> pack.song_lists end)
  def messages,         do: Agent.get(__MODULE__, fn pack -> pack.messages end)
  def message_bindings, do: Agent.get(__MODULE__, fn pack -> pack.message_bindings end)
  def code_bindings,    do: Agent.get(__MODULE__, fn pack -> pack.code_bindings end)
  def use_midi?,        do: Agent.get(__MODULE__, fn pack -> pack.use_midi end)
  def loaded_file,      do: Agent.get(__MODULE__, fn pack -> pack.loaded_file end)

  def song_list, do: Agent.get(__MODULE__, fn pack -> pack.cursor.song_list end)
  def song,      do: Agent.get(__MODULE__, fn pack -> pack.cursor.song end)
  def patch,     do: Agent.get(__MODULE__, fn pack -> pack.cursor.patch end)

  def next_patch do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: cursor |> Cursor.next_patch}
    end)
  end
  def prev_patch do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: cursor |> Cursor.prev_patch}
    end)
  end
  def next_song do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: cursor |> Cursor.next_song}
    end)
  end
  def prev_song do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: cursor |> Cursor.prev_song}
    end)
  end

  def add_song(song) do
    list = all_songs
      |> SongList.add_song(song)
      |> SongList.sort_by_name
    Agent.update(__MODULE__, fn pack -> %{pack | all_songs: list} end)
  end

  def load(_file) do
  end

  def save(_file) do
  end

  # TODO all accessors: add/remove song, song list, message, bindings, etc.

  def bind_message(_name, _key) do
  end

  def bind_code(_code_key) do
  end
end
