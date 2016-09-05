defmodule Blister.CursorTest do
  use ExUnit.Case
  doctest Blister.Cursor
  alias Blister.{Cursor, Pack, Patch}

  @testfile "examples/test.exs"

  setup do
    Pack.load(@testfile)
    pack = Pack.pack
    {:ok, %{cursor: pack.cursor, pack: pack}}
  end

  @tag :initialization
  test "handles nils" do
    c = %Cursor{} |> Cursor.init(%{song_lists: []})
    assert c.song_list == []
    assert c.song == nil
    assert c.patch_pid == nil
  end

  @tag :initialization
  test "initialized by pack", context do
    c = context[:cursor]
    assert_cursor(c, 1, 1, 1)
  end

  @tag :movement
  test "next_song", context do
    c = context[:cursor] |> Cursor.next_song(context[:pack])
    assert_cursor(c, 1, 2, 1)
  end

  @tag :movement
  test "next_song, end of song list, go to first song in next list", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    assert_cursor(c, 2, 3, 1)
  end

  @tag :movement
  test "next_song, end of everything, stay on song", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    assert_cursor(c, 2, 2, 1)
  end

  @tag :movement
  test "prev_song", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.prev_song(context[:pack])
    assert_cursor(c, 1, 1, 1)
  end

  @tag :movement
  test "prev_song, beginning of song list, go to last song in prev list", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.prev_song(context[:pack])
    assert_cursor(c, 1, 2, 1)
  end

  @tag :movement
  test "prev_song, no prev song, beginning of everything, stay on song", context do
    c = context[:cursor] |> Cursor.prev_song(context[:pack])
    assert_cursor(c, 1, 1, 1)
  end

  @tag :movement
  test "next_patch", context do
    c = context[:cursor] |> Cursor.next_patch(context[:pack])
    assert_cursor(c, 1, 1, 2)
  end

  @tag :movement
  test "next_patch, end of song, go to next song", context do
    c = context[:cursor]
    |> Cursor.next_patch(context[:pack])
    |> Cursor.next_patch(context[:pack])
    assert_cursor(c, 1, 2, 1)
  end

  @tag :movement
  test "next_patch, end of list, go to next song", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_patch(context[:pack])
    |> Cursor.next_patch(context[:pack])
    assert_cursor(c, 2, 3, 1)
  end

  @tag :movement
  test "next_patch, no next patch, stay on patch", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_patch(context[:pack])
    |> Cursor.next_patch(context[:pack])
    assert_cursor(c, 2, 2, 2)
  end

  @tag :movement
  test "prev_patch", context do
    c = context[:cursor]
    |> Cursor.next_patch(context[:pack])
    |> Cursor.prev_patch(context[:pack])
    assert_cursor(c, 1, 1, 1)
  end

  @tag :movement
  test "prev_patch, beginning of song, go to last patch of prev song", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.prev_patch(context[:pack])
    assert_cursor(c, 1, 1, 2)
  end

  @tag :movement
  test "prev_patch, beginning of first song in list, go to last patch of last song in prev list", context do
    c = context[:cursor]
    |> Cursor.next_song(context[:pack])
    |> Cursor.next_song(context[:pack])
    |> Cursor.prev_patch(context[:pack])
    assert_cursor(c, 1, 2, 2)
  end

  @tag :movement
  test "prev_patch, no prev patch, stay on patch", context do
    c = context[:cursor] |> Cursor.prev_patch(context[:pack])
    assert_cursor(c, 1, 1, 1)
  end

  @tag :search
  test "goto_song when song is in song list", context do
    c = context[:cursor]
    |> Cursor.next_song_list(context[:pack])
    |> Cursor.goto_song(context[:pack], "thi")
    assert_cursor(c, 2, 3, 1)
  end

  @tag :search
  test "goto_song when song is not in song list", context do
    c = context[:cursor] |> Cursor.goto_song(context[:pack], "thi")
    assert_cursor(c, 0, 3, 1)
  end

  defp assert_cursor(cursor, expected_list, expected_song, expected_patch) do
    expected_list_name = case expected_list do
                           0 -> "All Songs"
                           1 -> "Tonight's Song List"
                           2 -> "Another Song List"
                         end
    assert cursor.song_list.name == expected_list_name
    expected_song_name = case expected_song do
                           1 -> "First Song"
                           2 -> "Second Song"
                           3 -> "Third Song"
                         end
    assert cursor.song.name == expected_song_name
    expected_patch_name = case expected_patch do
                            1 -> "#{expected_song_name}, First Patch"
                            2 -> "#{expected_song_name}, Second Patch"
                          end
    assert Patch.name(cursor.patch_pid) == expected_patch_name
  end
end
