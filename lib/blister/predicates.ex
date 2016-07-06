defmodule Blister.Predicates do
  @moduledoc """
  Predicate functions and a few other byte array utility functions.
  """

  use Bitwise

  def channel?({b, _, _}) when b < 0xf0, do: true
  def channel?(_), do: false

  def note?({b, _, _}) when (b &&& 0xf0) < 0xb0, do: true
  def note?(_), do: false

  def channel({status, _, _}), do: status &&& 0x0f
  def channel(status) when is_integer(status), do: status &&& 0x0f
end
