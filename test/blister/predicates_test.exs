defmodule Blister.PredicatesTest do
  use ExUnit.Case
  alias Blister.Predicates, as: P

  test "channel?" do
    assert P.channel?({0x80, 0, 0}) == true
    assert P.channel?({0xef, 0, 0}) == true
    assert P.channel?(0xc8) == true
    assert P.channel?({0xf0, 0, 0}) == false
  end

  test "note?" do
    assert P.note?({0x80, 0, 0}) == true
    assert P.note?({0x92, 0, 0}) == true
    assert P.note?({0xaf, 0, 0}) == true
    assert P.note?(0x92) == true
    assert P.note?({0xb0, 0, 0}) == false
  end

  test "note_off?" do
    assert P.note_off?({0x80, 0, 0}) == true
    assert P.note_off?({0xaf, 0, 0}) == false
    assert P.note_off?(0x82) == true
    assert P.note_off?(0x92) == false
    assert P.note_off?({0xb0, 0, 0}) == false
  end

  test "note_on?" do
    assert P.note_on?({0x80, 0, 0}) == false
    assert P.note_on?({0x90, 0, 0}) == true
    assert P.note_on?({0xaf, 0, 0}) == false
    assert P.note_on?(0x82) == false
    assert P.note_on?(0x92) == true
    assert P.note_on?({0xb0, 0, 0}) == false
  end

  test "controller?" do
    assert P.controller?({0x80, 0, 0}) == false
    assert P.controller?({0xbf, 127, 0}) == true
    assert P.controller?(0x82) == false
    assert P.controller?(0xbf) == true
  end

  test "pc?" do
    assert P.pc?({0xc1, 127, 0}) == true
    assert P.pc?({0xc8, 0, 127}) == true
    assert P.pc?({0xc8, 0, 128}) == true # ignores data bytes
    assert P.pc?(0xc3) == true
  end

  test "channel" do
    assert P.channel(0x80) === 0
    assert P.channel({0xba, 0, 0}) === 10
  end
end
