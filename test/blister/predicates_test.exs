defmodule Blister.PredicatesTest do
  use ExUnit.Case
  alias Blister.Predicates, as: P

  test "channel?" do
    assert P.channel?({0x80, 0, 0}) == true
    assert P.channel?({0xEF, 0, 0}) == true
    assert P.channel?(0xC8) == true
    assert P.channel?({0xF0, 0, 0}) == false
  end

  test "note?" do
    assert P.note?({0x80, 0, 0}) == true
    assert P.note?({0x92, 0, 0}) == true
    assert P.note?({0xAF, 0, 0}) == true
    assert P.note?(0x92) == true
    assert P.note?({0xB0, 0, 0}) == false
  end

  test "note_off?" do
    assert P.note_off?({0x80, 0, 0}) == true
    assert P.note_off?({0xAF, 0, 0}) == false
    assert P.note_off?(0x82) == true
    assert P.note_off?(0x92) == false
    assert P.note_off?({0xB0, 0, 0}) == false
  end

  test "note_on?" do
    assert P.note_on?({0x80, 0, 0}) == false
    assert P.note_on?({0x90, 0, 0}) == true
    assert P.note_on?({0xAF, 0, 0}) == false
    assert P.note_on?(0x82) == false
    assert P.note_on?(0x92) == true
    assert P.note_on?({0xB0, 0, 0}) == false
  end

  test "controller?" do
    assert P.controller?({0x80, 0, 0}) == false
    assert P.controller?({0xBF, 127, 0}) == true
    assert P.controller?(0x82) == false
    assert P.controller?(0xBF) == true
  end

  test "pc?" do
    assert P.pc?({0xC1, 127, 0}) == true
    assert P.pc?({0xC8, 0, 127}) == true
    # ignores data bytes
    assert P.pc?({0xC8, 0, 128}) == true
    assert P.pc?(0xC3) == true
  end

  test "channel" do
    assert P.channel(0x80) === 0
    assert P.channel({0xBA, 0, 0}) === 10
  end
end
