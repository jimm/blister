defmodule Blister.SongListTest do
  use ExUnit.Case
  alias Blister.{SongList, Song}

  setup do
    s = %Song{name: "hello"}
    other = %Song{name: "other"}
    sl = %SongList{songs: [other, s]}
    {:ok, %{song: s, other: other, slist: sl}}
  end

  test "finds song with name", context do
    assert SongList.find_index(context[:slist], "he..o") == 1
  end

  test "finds song with name case insensitively", context do
    assert SongList.find_index(context[:slist], "HE..O") == 1
  end

  test "returns nil with no match", context do
    assert SongList.find_index(context[:slist], "nope") == nil
  end

  test "returns nil with bad regex", context do
    assert SongList.find_index(context[:slist], "[") == nil
  end

  test "returns nil with empty list" do
    assert SongList.find_index(%SongList{songs: []}, "he..o") == nil
  end
end
