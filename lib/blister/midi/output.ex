defmodule Blister.MIDI.Output do
  use GenServer
  use Blister.MIDI.IO, type: :output

  defmodule State do
    defstruct [:io]
  end

  # ================ Public API ================
  #
  # See also Blister.MIDI.IO

  def start_link(driver, name) do
    {:ok, out_pid} = driver.open(:output, name)

    GenServer.start_link(__MODULE__, %State{
      io: %Blister.MIDI.IO{driver: driver, port_pid: out_pid, port_name: name}
    })
  end

  def write(pid, messages), do: GenServer.cast(pid, {:write, messages})

  # ================ GenServer ================

  def handle_cast({:write, messages}, state) when is_list(messages) do
    state.io.driver.write(state.io.port_pid, Enum.map(messages, &add_timestamp/1))
    {:noreply, state}
  end

  def handle_cast({:write, message}, state) do
    state.io.driver.write(state.io.port_pid, [add_timestamp(message)])
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    :ok = close(state)
    {:stop, :normal, nil}
  end

  # ================ Helpers ================

  defp add_timestamp({{_, _, _}, _} = with_ts), do: with_ts
  defp add_timestamp({_, _, _} = msg), do: {msg, 0}
end
