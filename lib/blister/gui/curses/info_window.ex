defmodule Blister.GUI.Curses.InfoWindow do

  defstruct [:win, :text]

  alias Blister.GUI.Curses
  alias Blister.GUI.Curses.Window
  require Logger

  def create(rect, title_prefix) do
    win = Window.create(rect, title_prefix)
    %__MODULE__{win: win, text: nil}
  end

  def set_text(iwin, text) do
    %{iwin | text: text}
  end

  def draw(%__MODULE__{win: w, text: text} = iwin) do
    Curses.draw_text_win(w, text)
    iwin
  end
end
