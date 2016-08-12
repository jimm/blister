defmodule Blister.MIDI.MockDriver do

  require Logger

  # ================ API ================

  def start_link do
    state = %{inputs: %{"input 1" => [], # received messages
                        "input 2" => []},
              outputs: %{"output 1" => [], # sent messages
                         "output 2" => []},
              input_refs: %{},  # maps ref to input name
              output_refs: %{}, # maps ref to output name
              listeners: %{}}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  def devices do
    GenServer.call(__MODULE__, :devices)
  end

  def open(:input, name) do
    GenServer.call(__MODULE__, {:open, :input, name})
  end

  def open(:output, name) do
    GenServer.call(__MODULE__, {:open, :output, name})
  end

  def close(:input, pid) do
    GenServer.call(__MODULE__, {:close, :input, pid})
  end

  def close(:output, pid) do
    GenServer.call(__MODULE__, {:close, :output, pid})
  end

  def listen(in_pid, listener) do
    GenServer.call(__MODULE__, {:listen, in_pid, listener})
  end

  def write(out_pid, messages) do
    GenServer.call(__MODULE__, {:write, out_pid, messages})
  end

  @doc "Used for testing. Sends messages to in_pid."
  def input(in_pid, messages) do
    GenServer.call(__MODULE__, {:input, in_pid, messages})
  end

  @doc "Testing: return messages received by input with `input_name`."
  def received_messages(input_name) do
    GenServer.call(__MODULE__, {:received_messages, input_name})
  end

  @doc "Testing: return messages sent to output with `output_name`."
  def sent_messages(output_name) do
    GenServer.call(__MODULE__, {:sent_messages, output_name})
  end

  @doc "for testing"
  def state, do: GenServer.call(__MODULE__, :state)

  # ================ Handlers ================

  def handle_call(:clear, _from, _state) do
    {:reply, :ok, %{inputs: %{"input 1" => [], # received messages
                              "input 2" => []},
                    outputs: %{"output 1" => [], # sent messages
                               "output 2" => []},
                    input_refs: %{},  # maps ref to input name
                    output_refs: %{}, # maps ref to output name
                    listeners: %{}}}
  end

  def handle_call(:devices, _from, state) do
    devices = %{input: state.inputs
                  |> Map.keys
                  |> Enum.map(fn name -> %{name: name} end)
                  |> Enum.into([]),
                output: state.outputs
                  |> Map.keys
                  |> Enum.map(fn name -> %{name: name} end)
                  |> Enum.into([])}
    {:reply, devices, state}
  end

  def handle_call({:open, :input, name}, _from, state) do
    ref = make_ref()
    {:reply, {:ok, ref}, %{state |
                           input_refs: Map.put(state.input_refs, ref, name)}}
  end

  def handle_call({:open, :output, name}, _from, state) do
    ref = make_ref()
    {:reply, {:ok, ref}, %{state |
                           output_refs: Map.put(state.output_refs, ref, name)}}
  end

  def handle_call({:close, :input, _pid}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:close, :output, _pid}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:listen, in_pid, listener}, _from, state) do
    listeners =
      state.listeners
      |> Map.update(in_pid, [listener], fn ls -> [listener|ls] end)
    {:reply, :ok, %{state | listeners: listeners}}
  end

  def handle_call({:write, out_pid, messages}, _from, state) do
    messages = case messages do
                 ms when is_list(ms) -> ms
                 ms -> [ms]
               end

    # Find output and append messages to sent messages for that output
    # out_pid is really a ref we generated with a call to open(:output, name)
    name = state.output_refs[out_pid]
    outputs = state.outputs |> Map.update(name, messages, &(&1 ++ messages))

    {:reply, :ok, %{state | outputs: outputs}}
  end

  @doc """
  Send `messages` to all listeners of `in_pid`. Remember what was sent.
  """
  def handle_call({:input, in_pid, messages}, _from, state) do
    # in_pid is really a ref we generated with a call to open(:input, name)
    state.listeners
    |> Map.get(in_pid, [])
    |> Enum.each(fn listener ->
      send(listener, {in_pid, messages})
    end)

    messages = case messages do
                 ms when is_list(ms) -> ms
                 ms -> [ms]
               end
    name = state.input_refs[in_pid]
    inputs = state.inputs |> Map.update(name, messages, &(&1 ++ messages))

    {:reply, :ok, %{state | inputs: inputs}}
  end

  def handle_call({:received_messages, input_name}, _from, state) do
    {:reply, state.inputs[input_name], state}
  end

  def handle_call({:sent_messages, output_name}, _from, state) do
    {:reply, state.outputs[output_name], state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def terminate(reason, state) do
    Logger.info("mock driver terminate")
    if state != :shutdown, do: Logger.info("mock driver reason #{inspect reason}")
  end
end
