defmodule Blister.Connection do
  @moduledoc """
  A Connection connects an Input to an Output. Whenever MIDI data arrives at
  the Input it is optionally modified or filtered, then the remaining
  modified data is sent to the Output.

  If `input.chan` is nil then all messages from `input` will be sent to
  `output`.
  """

  defmodule ConnIO do
    defstruct [:sym, :pid, :chan]
  end

  # ConnIO structs
  defstruct [:input, :output, :filter, :zone, :xpose, :bank_msb, :bank_lsb, :pc_prog]

  use Bitwise
  alias Blister.MIDI.{Input, Output}
  alias Blister.Consts, as: C
  alias Blister.Predicates, as: P

  @doc """
  Tell `conn`'s input to start sending messages to this connection and send
  `start_messages` plus bank and program changes to all outputs.
  """
  def start(conn, start_messages \\ []) do
    Input.add_connection(conn.input.pid, conn)
    messages = start_messages

    messages =
      if conn.pc_prog do
        [{C.program_change() + conn.output.chan, conn.pc_prog, 0} | messages]
      else
        messages
      end

    messages =
      if conn.bank_lsb do
        [{C.controller(conn.output.chan), C.cc_bank_select_lsb(), conn.bank_lsb} | messages]
      else
        messages
      end

    messages =
      if conn.bank_msb do
        [{C.controller(conn.output.chan), C.cc_bank_select_msb(), conn.bank_msb} | messages]
      else
        messages
      end

    midi_out(conn, messages)
  end

  def stop(conn, stop_messages \\ []) do
    midi_out(conn, stop_messages)
    Input.remove_connection(conn.input.pid, conn)
  end

  @doc """
  The workhorse, called by an input when it receives MIDI data. Ignores
  messages that aren't from our input channel or are outside the zone.
  Filters. Changes to output channel.

  Note that running status bytes are not handled, but PortMidi doesn't seem
  to use them anyway.
  """
  def midi_in(conn, message) when is_tuple(message) do
    midi_in(conn, [message])
  end

  def midi_in(conn, messages) when is_list(messages) do
    midi_out(conn, process(conn, messages) |> Enum.to_list())
  end

  @doc """
  Takes `messages`, removes timestamps, filters out messages that don't
  qualify (wrong channel or out of zone, for example), then munges them by
  transposing, running through filter func, etc. Returns a Stream.

  This is only public so we can test it.
  """
  def process(conn, messages) do
    messages
    |> Stream.filter(&accept_from_input?(conn, &1))
    |> Stream.map(&munge(conn, &1))
  end

  def midi_out(_, nil), do: nil
  def midi_out(_, []), do: nil
  def midi_out(%__MODULE__{output: %ConnIO{pid: nil}}, _), do: nil

  def midi_out(%__MODULE__{output: %ConnIO{pid: pid}}, messages) do
    Output.write(pid, messages)
  end

  defp accept_from_input?(conn, message) do
    cond do
      conn.input.chan == nil ->
        true

      !P.channel?(message) ->
        true

      P.note?({_, note, _} = message) ->
        P.channel(message) == conn.input.chan && inside_zone?(conn, note)

      true ->
        true
    end
  end

  # Returns true if the zone is nil (allowing all notes through) or if
  # zone is a Range and `note` is inside the zone.
  defp inside_zone?(conn, note) do
    conn.zone == nil || Enum.member?(conn.zone, note)
  end

  # Convert a single message into whatever we want to send. Return nil if
  # nothing should be sent.
  #
  # First transpose is applied, then filter function
  defp munge(conn, message) do
    msg =
      cond do
        P.note?(message) ->
          # note off, note on, poly pressure
          munge_note(conn, message)

        P.channel?(message) ->
          # controller, program change, channel pressure, pitch bend
          munge_chan_message(conn, message)

        true ->
          # system messages
          message
      end

    if conn.filter do
      conn.filter.(conn, msg)
    else
      msg
    end
  end

  defp munge_note(conn, {status, note, val}) do
    munge_chan_message(conn, {status, xpose(conn.xpose, note), val})
  end

  defp xpose(nil, note), do: note
  defp xpose(xpose, note), do: min(127, max(0, note + xpose))

  defp munge_chan_message(conn, {status, b1, b2}) do
    status = (status &&& 0xF0) + conn.output.chan
    {status, b1, b2}
  end
end
