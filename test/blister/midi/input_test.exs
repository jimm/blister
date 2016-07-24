defmodule Blister.MIDI.InputTest do
  use ExUnit.Case
  alias Blister.{MIDI, Connection}
  alias Blister.MIDI.{Input, Output}
  alias Blister.MIDI.MockDriver, as: MD
  require Logger

  setup do
    in_pid = MIDI.input("input 1")
    out_pid = MIDI.output("output 1")
    conn = %Connection{input_pid: in_pid, input_chan: nil,
                       output_pid: out_pid, output_chan: 0}
    Connection.start(conn)      # adds conn to input's connections

    on_exit fn -> MD.clear end
    {:ok, %{in_pid: in_pid, out_pid: out_pid, conn: conn}}
  end

  test "sends received messages to connections", context do
    messages = [{0x90, 64, 127}, {0x80, 64, 127}]
    Logger.debug "test calling receive messages" # DEBUG
    Input.receive_messages(context[:in_pid], hd(messages))
    Logger.debug "test calling receive messages" # DEBUG
    :ok = Input.receive_messages(context[:in_pid], hd(tl(messages)))
    Logger.debug "test calling sent messages" # DEBUG

    assert MD.sent_messages("output 1") == messages
  end

  # test "receives messages via listener", context do
  # end
end
