defmodule Blister.GUI.TriggerWindow do

  alias Blister.GUI.Window

  def draw(twin) do
    Window.draw(twin)
    # i = 0
    # pm.inputs.each do |instrument|
    #   instrument.triggers.each do |trigger|
    #     if i < visible_height
    #       @win.setpos(i+1, 1)
    #       @win.addstr(make_fit(":#{instrument.sym} #{trigger.to_s}"))
    #     end
    #     i += 1
    #   end
    # end
    twin
  end
end

