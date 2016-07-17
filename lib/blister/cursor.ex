defmodule Blister.Cursor do

  @moduledoc """
  A Cursor knows the current SongList, Song, and Patch, how to move between
  songs and patches, and how to find them given name regexes.

  We search for items in lists instead of storing indexes to them. That's so
  that when items are added/removed we don't need to keep the indexes here
  up to date.
  """

  defstruct song_list_index: 0, song_list: [],
    song_index: 0, song: nil,
    patch_index: 0, patch: nil,
    song_list_name: nil,
    song_name: nil,
    patch_name: nil

  alias Blister.{Patch, SongList}

  # TODO call this every time we add a new song or patch
  def init(cursor, pack) do
    song_list_index = 0
    song_list = first_of(pack.song_lists)
    song = first_of(song_list)
    patch = if song, do: first_of(song.patches)
    %{cursor |
      song_list_index: song_list_index, song_list: song_list,
      song_index: 0, song: song,
      patch_index: 0, patch: patch}
  end

  def next_song(%{song_list: nil} = cursor, _), do: cursor
  def next_song(%{song_list: %SongList{songs: []}} = cursor, _), do: cursor
  def next_song(cursor) do
    new_song_index = cursor.song_index + 1
    if new_song_index < length(cursor.song_list) do
      Patch.stop(cursor.patch)
      song = cursor.song_list.songs |> Enum.at(new_song_index)
      patch = song.patches |> hd
      new_patch_index = 0
      Patch.start(patch)
      %{cursor |
        song_index: new_song_index, song: song,
        patch_index: new_patch_index, patch: patch}
    else
      cursor
    end
  end

  def prev_song(%{song_list: nil} = cursor), do: cursor
  def prev_song(%{song_list: %SongList{songs: []}} = cursor), do: cursor
  def prev_song(cursor) do
    new_song_index = cursor.song_index - 1
    if new_song_index >= 0 do
      Patch.stop(cursor.patch)
      song = cursor.song_list.songs |> Enum.at(new_song_index)
      new_patch_index = 0
      patch = song.patches |> hd
      Patch.start(patch)
      %{cursor |
        song_index: new_song_index, song: song,
        patch_index: new_patch_index, patch: patch}
    else
      cursor
    end
  end

  def next_patch(%{song: nil} = cursor, _), do: cursor
  def next_patch(%{song: %{patches: []}} = cursor, _), do: cursor
  def next_patch(cursor) do
    new_patch_index = cursor.patch_index + 1
    if new_patch_index < length(cursor.song.patches) do
      Patch.stop(cursor.patch)
      patch = cursor.song.patches |> Enum.at(new_patch_index)
      Patch.start(patch)
      %{cursor | patch_index: new_patch_index, patch: patch}
    end
  end

  def prev_patch(%{song: nil} = cursor), do: cursor
  def prev_patch(%{song: %{patches: []}} = cursor), do: cursor
  def prev_patch(cursor) do
    new_patch_index = cursor.patch_index - 1
    if new_patch_index >= 0 do
      Patch.stop(cursor.patch)
      patch = cursor.song.patches |> Enum.at(new_patch_index)
      Patch.start(patch)
      %{cursor | patch_index: new_patch_index, patch: patch}
    end
  end

  def goto_song(cursor, pack, name_regex_str) do
    new_song = if cursor.song_list do
      SongList.find(cursor.song_list, name_regex_str)
    end
    new_song = new_song || SongList.find(pack.all_songs, name_regex_str)
    new_patch = if new_song, do: hd(new_song.patches), else: nil

    if new_song && new_song != cursor.song || # moved to new song
       (new_song == cursor.song && cursor.patch != new_patch) do # same song, new patch
      Patch.stop(cursor.patch)

      new_song_list = if Enum.find(cursor.song_list.songs, fn s -> s == new_song end) do
        cursor.song_list
      else
        # Not found in current song list. Switch to list of all songs.
        pack.all_songs
      end

      Patch.start(new_patch)
      %{cursor | song_list: new_song_list, song: new_song, patch: new_patch}
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
      song = first_of(new_song_list)
      patch = if song, do: first_of(song.patches), else: nil
      if patch != cursor.patch do
        Patch.stop(cursor.patch)
        Patch.start(patch)
      end
      %{cursor | song_list: new_song_list, song: song, patch: patch}
    end
  end

  @doc """
  Remembers the names of the current song list, song, and patch.
  Used by `restore`.
  """
  def mark(cursor) do
    %{cursor | song_list_name: (if cursor.song_list, do: cursor.song_list.name),
      song_name: (if cursor.song, do: cursor.song.name),
      patch_name: (if cursor.patch, do: cursor.patch.name)}
  end

  @doc """
  Using the names saved by `save`, try to find them now.

  Since names can change we use Damerau-Levenshtein distance on lowercase
  versions of all strings.
  """
  def restore(%{song_list_name: nil} = cursor, _), do: cursor
  def restore(cursor, pack) do
    song_list = find_nearest_match(pack.song_lists, cursor.song_list_name) || pack.all_songs
    song = find_nearest_match(song_list.songs, cursor.song_name) || first_of(song_list.songs)
    patch = if song do
      find_nearest_match(song.patches, cursor.patch_name) || hd(song.patches)
    end

    %{cursor | song_list: song_list, song: song, patch: patch}
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

  defp first_of(nil), do: nil
  defp first_of([]), do: nil
  defp first_of(list), do: hd(list)

  defp last_of(nil), do: nil
  defp last_of([]), do: nil
  defp last_of(list), do: hd(Enum.reverse(list))

  defp index_of(nil, _), do: nil
  defp index_of([], _), do: nil
  defp index_of(list, val) do
    list |> Enum.find_index(fn elem -> elem == val end)
  end
end
