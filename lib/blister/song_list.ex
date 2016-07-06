defmodule Blister.SongList do
  @moduledoc """
  A SongList is a named list of Songs.
  """

  defstruct name: "Unnamed",
    songs: []

  def find(%__MODULE__{songs: songs}, name_regex_str) do
    case Regex.compile(name_regex_str, "i") do
      {:ok, r} ->
        Enum.find(songs, fn s -> Regex.match?(r, s.name) end)
      {:error, _} -> nil
    end
  end
end
