defmodule Blister.Trigger do
  @moduledoc """
  A Trigger executes code when it sees a particular array of bytes.
  Instruments have zero or more triggers.
  """

  defstruct [:bytes, :func]

  def signal(%__MODULE__{bytes: [b0, b1, b2]} = trigger, {b0, b1, b2}) do
    do_signal(trigger.func)
  end

  def signal(%__MODULE__{bytes: [b0, b1]} = trigger, {b0, b1, _}) do
    do_signal(trigger.func)
  end

  def signal(%__MODULE__{bytes: [b0]} = trigger, {b0, _, _}) do
    do_signal(trigger.func)
  end

  def signal(_, _) do
    nil
  end

  def do_signal(func) do
    func.()
    # TODO how notify Web front end?
    # Blister.Pack.gui.update
  end
end
