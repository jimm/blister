defmodule Blister.SongList do
  @moduledoc """
  A SongList is a named list of Songs.
  """

  defstruct name: "Unnamed",
    songs: []

  @doc """
  Return the first song that matches `name_regex_str`.
  """
  def find_index(%__MODULE__{songs: songs}, name_regex_str) do
    case Regex.compile(name_regex_str, "i") do
      {:ok, r} -> Enum.find_index(songs, fn s -> Regex.match?(r, s.name) end)
      {:error, _} -> nil
    end
  end

  @doc """
  Return a new `SongList` with the list of songs sorted by name.
  """
  def sort_by_name(%__MODULE__{songs: songs} = list) do
    %{list | songs: songs |> Enum.sort_by(&(&1.name))}
  end

  @doc """
  Add `song` to a song `list`.
  """
  def add_song(%__MODULE__{songs: songs} = list, song) do
    %{list | songs: [song | songs]}
  end
end
