defmodule Blister.MIDI.IO do
  @moduledoc """
  Common data and behavior for MIDI inputs and outputs.

  Modules that implement this behavior must be GenServers, and their state
  must contain an IO struct stored as `:io`. That is, `state.io` must return
  an IO struct.
  """

  defstruct [:driver, :port_pid, :port_name]

  @callback port_pid(pid) :: pid
  @callback port_name(pid) :: String.t
  @callback stop(pid) :: term

  @doc false
  defmacro __using__(type: type) do
    quote location: :keep do
      @behaviour Blister.MIDI.IO

      # ================ API ================

      @doc false
      def port_pid(pid) when is_pid(pid) do
        GenServer.call(pid, :port_pid)
      end

      @doc false
      def port_name(pid) when is_pid(pid) do
        GenServer.call(pid, :port_name)
      end

      def stop(pid), do: GenServer.cast(pid, :stop)

      def close(state) do
        state.io.driver.close(unquote(type), state.io.port_pid)
      end

      # ================ handlers ================

      def handle_call(:port_pid, _from, state) do
        {:reply, state.io.port_pid, state}
      end

      def handle_call(:port_name, _from, state) do
        {:reply, state.io.port_name, state}
      end
    end
  end
end
