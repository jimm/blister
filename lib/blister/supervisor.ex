defmodule Blister.Supervisor do
  use Supervisor
  alias Blister.{Pack, MIDI, Web}

  def start_link(driver_module) do
    Supervisor.start_link(__MODULE__, driver_module, name: :blister_supervisor)
  end

  def init(driver_module) do
    children =
      [worker(Pack, []), worker(MIDI, [driver_module]), worker(Web, [])]
    supervise(children, strategy: :one_for_one)
  end

  def quit do
    MIDI.cleanup
    :init.stop
  end
end
