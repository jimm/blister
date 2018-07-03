defmodule Blister.Supervisor do
  use Supervisor
  alias Blister.{Pack, MIDI, Web}

  def start_link(driver_module, use_gui) do
    Supervisor.start_link(__MODULE__, [driver_module, use_gui], name: :blister_supervisor)
  end

  def init([driver_module, use_gui]) do
    children =
      [worker(Pack, []), worker(MIDI, [driver_module])] ++
        if use_gui, do: [worker(Web, [])], else: []

    supervise(children, strategy: :one_for_one)
  end

  def quit do
    MIDI.cleanup()
    :init.stop()
  end
end
