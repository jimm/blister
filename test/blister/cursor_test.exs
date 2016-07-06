defmodule Blister.CursorTest do
  use ExUnit.Case
  doctest Blister.Cursor
  alias Blister.Cursor

  test "handles nils" do
    c = %Cursor{} |> Cursor.init
    assert c.song_list == nil
    assert c.song == nil
    assert c.patch == nil
  end
end
