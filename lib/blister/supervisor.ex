defmodule Blister.Supervisor do
  use Supervisor
  alias Blister.{Pack, MIDI, Controller}

  def start_link(driver_module, gui_module) do
    Supervisor.start_link(__MODULE__, [driver_module, gui_module], name: :blister_supervisor)
  end

  def init([driver_module, gui_module]) do
    children =
      [worker(Pack, []), worker(MIDI, [driver_module])] ++
      gui_workers(gui_module)
    supervise(children, strategy: :one_for_one)
  end

  def quit do
    MIDI.cleanup
    :init.stop
  end

  defp gui_workers(gui_module) do
    [worker(gui_module, []),
     worker(Controller, [gui_module])]
  end
end
