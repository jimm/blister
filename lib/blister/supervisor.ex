defmodule Blister.Supervisor do
  use Supervisor
  alias Blister.{Pack, MIDI, Controller}

  def start_link(gui_module) do
    Supervisor.start_link(__MODULE__, gui_module, name: :blister_supervisor)
  end

  def init(gui_module) do
    children = [
      worker(Pack, []),
      worker(MIDI, []),
      worker(gui_module, []),
      worker(Controller, [gui_module])
    ]
    supervise(children, strategy: :one_for_one)
  end

  def quit do
    MIDI.cleanup
    :init.stop
  end
end
