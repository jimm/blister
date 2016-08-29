defmodule Blister.Pack do
  @moduledoc """
  Holds all state related to a single Blister setup: all songs and patches,
  what file was loaded, etc.
  """

  require Logger
  alias Blister.{Cursor, SongList, DSL}

  defstruct inputs: %{},        # symbol => {display name, input pid}
    outputs: %{},               # symbol => {display name, output pid}
    all_songs: %SongList{name: "All Songs"},
    song_lists: [],
    messages: %{},              # name => bytes
    message_bindings: %{},
    triggers: %{},              # symbol => [{bytes, func}, ...]
    code_bindings: %{},
    use_midi: true,
    loaded_file: nil,
    cursor: %Cursor{}

  def start_link do
    Logger.info("pack init")
    Agent.start_link(
      fn ->
        pack = %__MODULE__{}
        %{pack | cursor: pack.cursor |> Cursor.init(pack)}
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
  def loaded_file,      do: Agent.get(__MODULE__, fn pack -> pack.loaded_file end)
  def cursor,           do: Agent.get(__MODULE__, fn pack -> pack.cursor end)

  def song_list, do: Agent.get(__MODULE__, fn pack -> pack.cursor.song_list end)
  def song,      do: Agent.get(__MODULE__, fn pack -> pack.cursor.song end)
  def patch,     do: Agent.get(__MODULE__, fn pack -> pack.cursor.patch end)

  def triggers,  do: Agent.get(__MODULE__, fn pack -> pack.triggers end)

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
  def next_song_list do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.next_song_list(pack)}
    end)
  end
  def prev_song_list do
    Agent.update(__MODULE__, fn pack ->
      %{pack | cursor: pack.cursor |> Cursor.prev_song_list(pack)}
    end)
  end

  def add_song(song) do
    list = all_songs()
      |> SongList.add_song(song)
      |> SongList.sort_by_name
    # TODO update cursor if necessary
    Agent.update(__MODULE__, fn pack -> %{pack | all_songs: list} end)
  end

  def send_message(_name) do
    # TODO
  end

  def load(file) do
    Logger.debug("load file #{file}")
    new_pack = DSL.load(file)
    Agent.update(__MODULE__, fn pack ->
      Logger.debug "init cursor using new pack" # DEBUG
      cursor = new_pack.cursor |> Blister.Cursor.init(new_pack)
      Logger.debug "cursor initialized, returning" # DEBUG
      %{new_pack | cursor: cursor, use_midi: pack.use_midi}
    end)
  end

  def save(file) do
    pack = Agent.get(__MODULE__, fn pack -> pack end)
    DSL.save(file, pack)
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

  @doc "For testing only."
  def pack, do: Agent.get(__MODULE__, fn pack -> pack end)
end
