defmodule Blister.CursorTest do
  use ExUnit.Case
  doctest Blister.Cursor
  alias Blister.{Cursor, Pack}

  @testfile "examples/test.exs"

  setup do
    Pack.load(@testfile)
    {:ok, %{cursor: Pack.cursor}}
  end

  test "handles nils" do
    c = %Cursor{} |> Cursor.init(%{song_lists: []})
    assert c.song_list == nil
    assert c.song == nil
    assert c.patch == nil
  end

  test "initialized by pack", context do
    c = context[:cursor]
    assert c.song.name == "First Song"
    assert c.patch.name == "First Song, First Patch"
    assert c.song_list.name == "Tonight's Song List"
  end

  test "next_song", context do
    c = context[:cursor] |> Cursor.next_song
    assert c.song.name == "Second Song"
  end

  test "next_song, no next song, stay on song", context do
    c = context[:cursor] |> Cursor.next_song |> Cursor.next_song
    assert c.song.name == "Second Song"
  end

  test "prev_song", context do
    c = context[:cursor] |> Cursor.next_song |> Cursor.prev_song
    assert c.song.name == "First Song"
  end

  test "prev_song, no prev song, stay on song", context do
    c = context[:cursor] |> Cursor.prev_song
    assert c.song.name == "First Song"
  end

  test "next_patch", context do
    c = context[:cursor] |> Cursor.next_patch
    assert c.patch.name == "First Song, Second Patch"
  end

  test "next_patch, no next patch, stay on patch", context do
    c = context[:cursor] |> Cursor.next_patch |> Cursor.next_patch
    assert c.patch.name == "First Song, Second Patch"
  end

  test "prev_patch", context do
    c = context[:cursor] |> Cursor.next_patch |> Cursor.prev_patch
    assert c.patch.name == "First Song, First Patch"
  end

  test "prev_patch, no prev patch, stay on patch", context do
    c = context[:cursor] |> Cursor.prev_patch
    assert c.patch.name == "First Song, First Patch"
  end
end
