defmodule Blister.Predicates do
  @moduledoc """
  Predicate functions and a few other PortMidi message utility functions.
  """

  use Bitwise

  def channel?({b, _, _}) when b < 0xf0, do: true
  def channel?(_), do: false

  def note?({b, _, _}) when (b &&& 0xf0) < 0xb0, do: true
  def note?(_), do: false

  def note_off?({b, _, _}) when (b &&& 0xf0) == 0x80, do: true
  def note_off?(_), do: false

  def note_on?({b, _, _}) when (b &&& 0xf0) == 0x90, do: true
  def note_on?(_), do: false

  def pc?({b, _, _}) when (b &&& 0xf0) == 0xc0, do: true
  def pc?(_), do: false

  def channel({status, _, _}), do: status &&& 0x0f
  def channel(status) when is_integer(status), do: status &&& 0x0f
end
