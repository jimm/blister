defmodule Blister.DSL do
  @moduledoc """
  This module is responsible for loading and saving Blister.Pack data.
  """

  alias Blister.{Pack, Connection}

  defmodule State do
    defstruct [:pack, :song, :patch]
  end

  def load(file) do
    code = "import #{__MODULE__}\n" <> File.read!(file)
    Agent.start_link(fn -> %State{pack: %Pack{}} end, name: __MODULE__)
    Code.eval_string(code, [], aliases: [{C, Blister.Consts}, {P, Blister.Pack}],
      file: file, line: 0)
    # TODO handle parsing errors
    pack = Agent.get(__MODULE__, fn state ->
      # TODO put state patch into song, put state song into pack
      state.pack
    end)
    Agent.stop(__MODULE__)
    pack
  end

  def save(_file, _pack) do
    # file |> File.write!(pack_to_setup(pack))
  end

  def input(_port_name, [{_sym, _name}]) do
  end

  def output(_port_name, [{_sym, _name}]) do
  end

  def alias_input(_from, _to) do
  end

  def alias_output(_from, _to) do
  end

  def message(_name, _bytes) do
  end

  def message_key(_key, _name) do
  end

  def trigger(_input, _bytes, _func) do
  end

  def song(_name, _patches) do
    # TODO put existing state song into state pack
  end

  def notes(notes) do
    notes
  end

  def patch(_name, _contents) do
    # TODO put existing state patch into state song
  end

  def start_bytes(bytes) do
    Agent.update(__MODULE__, fn state -> %{state | start_bytes: bytes} end)
  end

  def stop_bytes(bytes) do
    Agent.update(__MODULE__, fn state -> %{state | stop_bytes: bytes} end)
  end

  def connection(input, input_chan \\ nil, output, output_chan, opts) do
    bank_msb = cond do
      opts[:bank_msb] -> opts[:bank_msb]
      {msb, _lsb} = opts[:bank] -> msb
      true -> nil
    end
    bank_lsb = cond do
      opts[:bank_lsb] -> opts[:bank_lsb]
      {_msb, lsb} = opts[:bank] -> lsb
      true -> nil
    end
    conn = %Connection{input_pid: input_pid_from_sym(input),
                       input_chan: input_chan,
                       output: output_from_sym(output),
                       output_chan: output_chan,
                       filter: opts[:filter],
                       zone: opts[:zone],
                       xpose: opts[:xpose] || opts[:transpose],
                       bank_msb: bank_msb,
                       bank_lsb: bank_lsb,
                       pc_prog: opts[:pc] || opts[:prog] || opts[:program]}
    Agent.update(__MODULE__, fn state ->
      %{state | patch: %{state.path | connections: [conn | state.patch.connections]}}
    end)
  end

  def conn(input, input_chan \\ nil, output, output_chan, opts) do
    connection(input, input_chan, output, output_chan, opts)
  end

  def c(input, input_chan \\ nil, output, output_chan, opts) do
    connection(input, input_chan, output, output_chan, opts)
  end

  defp input_pid_from_sym(_sym) do
    nil                         # TODO
  end

  defp output_from_sym(_sym) do
    nil                         # TODO
  end
end
