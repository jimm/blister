defmodule Blister.Connection do
  @moduledoc """
  A Connection connects an Input to an Output. Whenever MIDI data arrives at
  the Input it is optionally modified or filtered, then the remaining
  modified data is sent to the Output.

  If `input_chan` is nil then all messages from `input` will be sent to
  `output`.
  """

  defstruct [:input_pid, :input_chan, :output_pid, :output_chan, :filter,
             :zone, :xpose, :bank_msb, :bank_lsb, :pc_prog]

  use Bitwise
  alias Blister.MIDI.{Input, Output}
  alias Blister.Consts, as: C
  alias Blister.Predicates, as: P

  def start(conn, start_messages \\ []) do
    Input.add_connection(conn.input_pid, conn)
    messages = start_messages
    messages = if conn.pc_prog do
      [{C.program_change + conn.output_chan, conn.pc_prog} | messages]
    else
      messages
    end
    messages = if conn.bank_lsb do
      [{C.controller + conn.outout_chan,
        C.cc_bank_select_lsb + conn.outout_chan,
        conn.bank_lsb} | messages]
    else
      messages
    end
    messages = if conn.bank_msb do
      [{C.controller + conn.outout_chan,
        C.cc_bank_select_msb + conn.outout_chan,
        conn.bank_msb} | messages]
    else
      messages
    end
    midi_out(conn, messages)
  end

  def stop(conn, stop_messages \\ []) do
    midi_out(conn, stop_messages)
    Input.remove_connection(conn.input_pid, conn)
  end

  @doc """
  The workhorse, called by an input when it receives MIDI data. Ignores
  messages that aren't from our input channel or are outside the zone.
  Filters. Changes to output channel.

  Note that running status bytes are not handled, but PortMidi doesn't seem
  to use them anyway.
  """
  def midi_in(conn, messages) when is_tuple(messages) do
    midi_in(conn, [messages])
  end
  def midi_in(conn, messages) do
    messages
    |> Stream.map(&remove_timestamp/1)
    |> Stream.filter(&accept_from_input?(conn, &1))
    |> Stream.map(&munge(conn, &1))
    |> Enum.map(&midi_out(conn, &1))
  end

  def remove_timestamp({{_, _, _}, t} = msg) when is_integer(t), do: msg
  def remove_timestamp({_, _, _} = msg), do: msg

  def accept_from_input?(conn, message) do
    cond do
      conn.input_chan == nil -> true
      !P.channel?(message) -> true
      true -> P.note?(message) && P.channel(message) == conn.input_chan
    end
  end

  # Returns true if the zone is nil (allowing all notes through) or if
  # zone is a Range and `note` is inside the zone.
  def inside_zone?(conn, note) do
    conn.zone == nil || Enum.member?(conn.zone, note)
  end

  # Convert a single message into whatever we want to send. Return nil if
  # nothing should be sent.
  defp munge(conn, {status, _, _} = message) do
    msg = cond do
      P.note?(status) ->
        # note off, note on, poly pressure
        munge_note(conn, message)
      P.channel?(status) ->
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
    if inside_zone?(conn, note) do
      note = if conn.xpose, do: note + conn.xpose, else: note
      if note >= 0 && note <= 127 do
        status = (status &&& 0xf0) + conn.output_chan
        {status, note, val}
      else
        nil
      end
    else
      nil
    end
  end

  defp munge_chan_message(conn, {status, b1, b2}) do
    status = (status &&& 0xf0) + conn.output_chan
    {status, b1, b2}
  end

  def midi_out(_, nil), do: nil
  def midi_out(_, []), do: nil
  def midi_out(%__MODULE__{output_pid: nil}, _), do: nil
  def midi_out(%__MODULE__{output_pid: pid}, messages) do
    Output.write(pid, messages)
  end
end
