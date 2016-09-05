defmodule Blister.Cursor do

  @moduledoc """
  A Cursor knows the current SongList, Song, and Patch, how to move between
  songs and patches, and how to find them given name regexes.

  When marking our position (before reloading a file), we store names
  instead of indexes in case things move around.
  """

  defstruct song_list_index: 0, song_list: [],
    song_index: 0, song: nil,
    patch_pid_index: 0, patch_pid: nil,
    song_list_name: nil,
    song_name: nil,
    patch_name: nil

  alias Blister.{Pack, Patch, SongList}

  def init(cursor, pack) do
    next_song_list(%{cursor | song_list_index: -1}, pack)
  end

  @doc """
  Move to the next patch. At the end of a song, go to the first patch of the
  next song in the active song list. If we are at the end of the last song
  in the list, don't go anywhere.
  """
  def next_patch(%__MODULE__{song: nil} = cursor), do: cursor
  def next_patch(cursor, pack) do
    new_patch_pid_index = cursor.patch_pid_index + 1
    if new_patch_pid_index >= length(cursor.song.patch_pids) do
      next_song(cursor, pack)
    else
      move_to_patch(cursor, new_patch_pid_index)
    end
  end

  @doc """
  Move to the previous patch. At the start of a song, go to the last patch
  of the previous song in the active song list. If we are at the start of
  the first song in the list, don't go anywhere.
  """
  def prev_patch(%__MODULE__{song: nil} = cursor), do: cursor
  def prev_patch(cursor, pack) do
    new_patch_pid_index = cursor.patch_pid_index - 1
    if new_patch_pid_index < 0 do
      prev_song(cursor, pack, :last)
    else
      move_to_patch(cursor, new_patch_pid_index)
    end
  end

  @doc """
  Move to the first patch of the next song. If this is the last song in the
  active song list, move to the next song list. If this is the last song of
  the last song list, don't go anywhere.
  """
  def next_song(%__MODULE__{song_list: nil} = cursor, _), do: cursor
  def next_song(cursor, pack) do
    new_song_index = cursor.song_index + 1
    if new_song_index >= length(cursor.song_list.songs) do
      next_song_list(cursor, pack)
    else
      song = cursor.song_list.songs |> Enum.at(new_song_index)
      move_to_patch(%{cursor | song_index: new_song_index, song: song}, :first)
    end
  end

  @doc """
  Move to the previous song. If this is the first song in the active song
  list, move to the last song in the previous song list. If this is the
  first song of the first song list, don't go anywhere.

  `which_patch` determines which patch in the song is our final destination.
  It must be either :first (the default) or :last.
  """
  def prev_song(cursor, pack, which_patch \\ :first)
  def prev_song(%__MODULE__{song_list: nil} = cursor, _, _), do: cursor
  def prev_song(cursor, pack, which_patch) do
    new_song_index = cursor.song_index - 1
    if new_song_index < 0 do
      prev_song_list(cursor, pack, :last, which_patch)
    else
      song = cursor.song_list.songs |> Enum.at(new_song_index)
      move_to_patch(%{cursor | song_index: new_song_index, song: song}, which_patch)
    end
  end

  @doc """
  Move to the first patch of the first song of the next song list. If this
  is the last song list, don't go anywhere.
  """
  def next_song_list(cursor, %Pack{song_lists: []}), do: cursor
  def next_song_list(cursor, pack) do
    new_song_list_index = cursor.song_list_index + 1
    if new_song_list_index >= length(pack.song_lists) do
      cursor
    else
      %{cursor |
        song_list_index: new_song_list_index,
        song_list: pack.song_lists |> Enum.at(new_song_list_index),
        song_index: -1}
      |> next_song(pack)
    end
  end

  @doc """
  Move to the first/last song of the previous song list. If this is the
  first song of the first song list, don't go anywhere.

  `which_song` and `which_patch` determine which patch in which song is our
  final destination. They must be either :first (the default) or :last.
  """
  def prev_song_list(cursor, pack, which_song \\ :first, which_patch \\ :first)
  def prev_song_list(cursor, %Pack{song_lists: []}, _, _), do: cursor
  def prev_song_list(cursor, pack, which_song, which_patch) do
    new_song_list_index = cursor.song_list_index - 1
    if new_song_list_index < 0 do
      cursor
    else
      song_list = pack.song_lists |> Enum.at(new_song_list_index)
      case which_song do
        :first ->
          %{cursor |
            song_list_index: new_song_list_index, song_list: song_list,
            song_index: -1}
          |> next_song(pack)
          :last ->
          %{cursor |
            song_list_index: new_song_list_index, song_list: song_list,
            song_index: length(song_list.songs)}
          |> prev_song(pack, which_patch)
      end
    end
  end

  def goto_song(cursor, pack, name_regex_str) do
    new_song_index = if cursor.song_list do
      SongList.find_index(cursor.song_list, name_regex_str)
    end

    {new_song_list_index, new_song_index} = if new_song_index do
      {cursor.song_list_index, new_song_index}
    else
      indexes = pack.song_lists
      |> Enum.map(fn sl -> SongList.find_index(sl, name_regex_str) end)
      index_of_index = indexes |> Enum.find(fn idx -> idx end)
      {index_of_index, indexes |> Enum.at(index_of_index)}
    end

    {new_song_list_index, new_song_index} = if new_song_index do
      {new_song_list_index, new_song_index}
    else
      idx = SongList.find_index(pack.all_songs, name_regex_str)
      if idx do
        {nil, idx}
      else
        {nil, nil}
      end
    end

    if new_song_list_index == nil && new_song_index == nil do
      cursor
    else
      song_list = if new_song_list_index do
        pack.song_lists |> Enum.at(new_song_list_index)
      else
        pack.all_songs
      end
      %{cursor |
        song_list_index: new_song_list_index,
        song_list: song_list,
        song_index: new_song_index,
        song: (if song_list, do: song_list.songs |> Enum.at(new_song_index))}
        |> move_to_patch(:first)
    end
  end

  def goto_song_list(cursor, pack, name_regex_str) do
    {:ok, r} = Regex.compile(name_regex_str, "i")
    new_song_list = pack.song_lists |> Enum.find(fn sl ->
      Regex.match?(r, sl.name)
    end)
    if new_song_list == nil do
      cursor
    else
      song = first_index_of(new_song_list.songs)
      patch_pid = if song, do: first_index_of(song.patch_pids), else: nil
      if patch_pid != cursor.patch_pid do
        Patch.stop(cursor.patch_pid)
        Patch.start(patch_pid)
      end
      %{cursor | song_list: new_song_list, song: song, patch_pid: patch_pid}
    end
  end

  @doc """
  Remembers the names of the current song list, song, and patch.
  Used by `restore`.
  """
  def mark(cursor) do
    %{cursor | song_list_name: (if cursor.song_list, do: cursor.song_list.name),
      song_name: (if cursor.song, do: cursor.song.name),
      patch_name: (if cursor.patch_pid, do: Patch.name(cursor.patch_pid))}
  end

  @doc """
  Using the names saved by `save`, try to find them now.

  Since names can change we use Damerau-Levenshtein distance on lowercase
  versions of all strings.
  """
  def restore(%__MODULE__{song_list_name: nil} = cursor, _), do: cursor
  def restore(cursor, pack) do
    song_list = find_nearest_match(pack.song_lists, cursor.song_list_name) || pack.all_songs
    song = find_nearest_match(song_list.songs, cursor.song_name) || first_index_of(song_list.songs)
    patch_pid = if song do
      find_nearest_match(song.patch_pids, cursor.patch_name) || hd(song.patch_pids)
    end

    %{cursor | song_list: song_list, song: song, patch_pid: patch_pid}
  end

  def find_nearest_match(nil, _), do: nil
  def find_nearest_match([], _), do: nil
  def find_nearest_match(_, nil), do: nil
  def find_nearest_match(list, str) do
    str = str |> String.downcase
    distances = list
    |> Enum.map(&damerau_levenshtein(str |> to_char_list,
                                     &1.name |> String.downcase |> to_char_list))
    min_dist = distances |> Enum.min
    index_of_min_dist = distances
    |> Enum.find_index(fn d -> d == min_dist end)
    list |> Enum.at(index_of_min_dist)
  end

  @doc """
  https://gist.github.com/mdemare/182759
  Referenced from http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance

  ## Examples:

    iex> Blister.Cursor.damerau_levenshtein('abc', 'abc')
    0
    iex> Blister.Cursor.damerau_levenshtein('abc', 'abcd')
    1
    iex> Blister.Cursor.damerau_levenshtein('abc', 'cde')
    3
    iex> Blister.Cursor.damerau_levenshtein('abcdef', 'abceef')
    1
    iex> Blister.Cursor.damerau_levenshtein('abcdef', 'bcdef')
    1
  """
  def damerau_levenshtein(seq1, seq2) do
    thisrow = ((1..length(seq2)) |> Enum.into([])) ++ [0]
    {_, row} =
      (0..length(seq1)-1)
      |> Enum.reduce({nil, thisrow}, fn(x, {twoago, oneago}) ->
           thisrow = [x+1 | List.duplicate(0, length(seq2))] |> Enum.reverse

           thisrow =
             (0..length(seq2)-1)
             |> Enum.reduce(thisrow, fn(y, trow) ->
                  delcost = Enum.at(oneago, y) + 1
                  addcost = Enum.at(trow, y - 1) + 1
                  offset = if Enum.at(seq1, x) != Enum.at(seq2, y), do: 1, else: 0
                  subcost = Enum.at(oneago, y - 1) + offset
                  trow = List.replace_at(trow, y, Enum.min([delcost, addcost, subcost]))
                  if x > 0 && y > 0 &&
                    Enum.at(seq1, x) == Enum.at(seq2, y-1) &&
                    Enum.at(seq1, x-1) == Enum.at(seq2, y) &&
                    Enum.at(seq1, x) != Enum.at(seq2, y)
                    do
                    List.replace_at(trow, y, Enum.min([Enum.at(trow, y), Enum.at(twoago, y-2) + 1]))
                    else
                      trow
                  end
           end)
          {oneago, thisrow}
      end)
    Enum.at(row, length(seq2) - 1)
  end

  # Stop the current patch (which is the "old" patch), move to the specified
  # patch in the current song, start the new one, and return a new cursor
  # with the new patch and patch index set.
  #
  # `which_patch` must be either :first (the default) or :last.
  defp move_to_patch(%__MODULE__{song: nil} = cursor, _) do
    move_to_patch(cursor, nil)
  end
  defp move_to_patch(cursor, :first) do
    move_to_patch(cursor, first_index_of(cursor.song.patch_pids))
  end
  defp move_to_patch(cursor, :last) do
    move_to_patch(cursor, last_index_of(cursor.song.patch_pids))
  end
  defp move_to_patch(cursor, patch_pid_index) do
    Patch.stop(cursor.patch_pid)
    patch_pid = if patch_pid_index do
      Enum.at(cursor.song.patch_pids, patch_pid_index)
    end
    Patch.start(patch_pid)
    %{cursor | patch_pid_index: patch_pid_index, patch_pid: patch_pid}
  end

  defp first_index_of(nil), do: nil
  defp first_index_of([]), do: nil
  defp first_index_of(xs) when is_list(xs), do: 0

  defp last_index_of(nil), do: nil
  defp last_index_of([]), do: nil
  defp last_index_of(xs), do: length(xs) - 1
end
