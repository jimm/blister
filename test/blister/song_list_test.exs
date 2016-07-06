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
    assert SongList.find(context[:slist], "he..o") == context[:song]
  end

  test "finds song with name case insensitively", context do
    assert SongList.find(context[:slist], "HE..O") == context[:song]
  end

  test "returns nil with no match", context do
    assert SongList.find(context[:slist], "nope") == nil
  end

  test "returns nil with bad regex", context do
    assert SongList.find(context[:slist], "[") == nil
  end

  test "returns nil with empty list" do
    assert SongList.find(%SongList{songs: []}, "he..o") == nil
  end
end
