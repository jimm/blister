defmodule Blister.GUI.Window do

  defstruct [:win, :r, :title_prefix, :title, :max_contents_len, :visible_height]

  require Logger

  @doc """
  Return a new Window struct.
  """
  def create({height, width, row, col} = r, title_prefix, title \\ nil) do
    w = :cecho.newwin(height, width, row, col)
    %__MODULE__{win: w,
                r: r,
                title_prefix: title_prefix, title: title,
                max_contents_len: width - 3, # 2 for borders
                visible_height: height - 2}  # ditto
  end

  @doc """
  Moves and resizes a Window. Not yet implemented.
  """
  def move_and_resize(win, {_height, _width, _row, _col}) do
    # TODO
    win
  end

  @doc """
  Set window title. Returns a new Window struct.
  """
  def set_title(win, title) do
    %{win | title: title}
  end

  @doc """
  Draw border and title.
  """
  def draw(%__MODULE__{win: win, title_prefix: title_prefix, title: title} = window) do
    Logger.debug("Window.draw title #{title}")
    :cecho.werase(win)
    :cecho.box(:cecho_consts.ceSTDSCR, :cecho_consts.ceACS_VLINE,
      :cecho_consts.ceACS_HLINE)

    :cecho.wmove(win, 0, 1)
    :cecho.attron(win, :cecho_consts.ceA_REVERSE)
    :cecho.waddch(win, ?\s)
    if title_prefix, do: :cecho.waddstr(win, "#{title_prefix}: ")
    if title, do: :cecho.waddstr(win, title)
    :cecho.waddch(win, ?\s)
    :cecho.attroff(win, :cecho_consts.ceA_REVERSE)

    window
  end

  @doc """
  Given a String `str`, return a possibly truncated string that will fit
  inside the window.
  """
  def make_fit(%__MODULE__{max_contents_len: mcl}, str) do
    str |> String.slice(0, mcl)
  end
end
