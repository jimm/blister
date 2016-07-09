defmodule Blister.Supervisor do
  use Supervisor
  alias Blister.{Pack, MIDI, GUI, Controller}

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :blister_supervisor)
  end

  def init(_) do
    children = [
      worker(Pack, []),
      worker(MIDI, []),
      worker(GUI, []),
      worker(Controller, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

  def quit do
    GUI.cleanup
    MIDI.cleanup
    :init.stop
  end
end
