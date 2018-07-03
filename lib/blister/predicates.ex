defmodule Blister.Predicates do
  @moduledoc """
  Predicate functions and a few other PortMidi message utility functions.

  The predication functions that look at status bytes (for example,
  `channel?` or `note_on?` ignore data byte values. They do not check to see
  if the data bytes are legal 7-bit values.
  """

  use Bitwise

  @doc """
  Returns true if message or status is a channel (non-system) message or
  status.
  """
  def channel?({b, _, _}) when b >= 0x80 and b < 0xf0, do: true
  def channel?(b) when is_integer(b) and b >= 0x80 and b < 0xf0, do: true
  def channel?(_), do: false

  @doc """
  Returns true if message or status byte is a note (note on, note off, poly
  pressure).
  """
  def note?({b, _, _}) when b >= 0x80 and b < 0xb0, do: true
  def note?(b) when is_integer(b) and  b >= 0x80 and b < 0xb0, do: true
  def note?(_), do: false

  @doc """
  Returns true if message or status byte is a note off.
  """
  def note_off?({b, _, _}) when b >= 0x80 and b < 0x90, do: true
  def note_off?(b) when is_integer(b) and b >= 0x80 and b < 0x90, do: true
  def note_off?(_), do: false

  @doc """
  Returns true if message or status byte is a note on.
  """
  def note_on?({b, _, _}) when b >= 0x90 and b < 0xa0, do: true
  def note_on?(b) when is_integer(b) and  b >= 0x90 and b < 0xa0, do: true
  def note_on?(_), do: false

  @doc """
  Returns true if message or status byte is a controller.
  """
  def controller?({b, _, _}) when b >= 0xb0 and b < 0xc0, do: true
  def controller?(b) when is_integer(b) and b >= 0xb0 and b < 0xc0, do: true
  def controller?(_), do: false

  @doc """
  Returns true if message or status byte is a program change.
  """
  def pc?({b, _, _}) when b >= 0xc0 and b < 0xd0, do: true
  def pc?(b) when is_integer(b) and b >= 0xc0 and b < 0xd0, do: true
  def pc?(_), do: false

  @doc """
  Returns the chanel nibble of a status byte in a message or a standalone
  status byte.

  iex> Blister.Predicates.channel({0x94, 0, 0})
  4
  """
  def channel({status, _, _}) when status >= 0x80 and status < 0xf0, do: status &&& 0x0f
  def channel(status) when is_integer(status) and status >= 0x80 and status < 0xf0, do: status &&& 0x0f
end
