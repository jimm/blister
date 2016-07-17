defmodule Blister.MIDI.IO do
  @moduledoc """
  Common data and behavior for MIDI inputs and outputs.

  Modules that implement this behavior must be GenServers, and their state
  must contain an IO struct stored as `:io`. That is, `state.io` must return
  an IO struct.
  """

  defstruct [:port_pid, :port_name, :display_name]

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour IO

      # ================ API ================

      @doc false
      def port_pid(pid) when is_pid(pid) do
        GenServer.call(pid, :port_pid)
      end
      def port_pid(state), do: state.io.port_pid

      @doc false
      def port_name(pid) when is_pid(pid) do
        GenServer.call(pid, :port_name)
      end
      def port_name(state), do: state.io.port_name

      @doc false
      def display_name(pid) when is_pid(pid) do
        GenServer.call(pid, :display_name)
      end
      def display_name(state), do: state.io.display_name

      @doc false
      def set_display_name(pid, name) when is_pid(pid) do
        GenServer.call(pid, {:set_display_name, name})
      end
      def set_display_name(state, name) do
        %{state | io: %{state.io | display_name: name}}
      end

      def stop(pid), do: GenServer.cast(pid, :stop)

      # ================ handlers ================

      def handle_call(:port_pid, _from, state) do
        {:reply, state.io.port_pid, state}
      end

      def handle_call(:port_pid, _from, state) do
        {:reply, state.io.port_pid, state}
      end

      def handle_call(:port_pid, _from, state) do
        {:reply, state.io.port_pid, state}
      end

      def handle_call(:port_pid, _from, state) do
        {:reply, state.io.port_pid, state}
      end
    end
  end
end
