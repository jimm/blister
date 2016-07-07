defmodule Bundle.GUI.Window do

  defstruct [:win, :title_prefix, :title, :max_contents_len, :visible_height]

  @doc """
  Return a new Window struct.
  """
  def create({height, width, row, col}, title_prefix, title \\ nil) do
    %__MODULE__{win: :cecho.newwin(rows, cols, row, col),
                title_prefix: title_prefix, title: title,
                max_contents_len: width - 3, # 2 for borders
                visible_height: height - 2}  # ditto
  end

  @doc """
  Moves and resizes a Window. Not yet implemented.
  """
  def move_and_resize(win, {height, width, row, col}) do
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
  def draw(%__MODULE__{win: win, title_prefix: title_prefix, title: title}) do
    :cecho.werase(win)
    :cecho.box(:cecho_consts.ceSTDSCR, :cecho_consts.ceACS_VLINE,
      :cecho_consts.ceACS_HLINE)

    :cecho.wmove(win, 0, 1)
    :cecho.attron(win, :cecho_consts.ceA_REVERSE)
    :cecho.waddch(win, ?\s)
    if title_prefix, do: :cecho.waddstr(win, "#{title_prefix}: ")
    if title, do: :cecho.addstr(win, title)
    :cecho.waddch(win, ?\s)
    :cecho.attroff(win, :cecho_consts.ceA_REVERSE)
  end

  @doc """
  Given a String `str`, return a possibly truncated string that will fit
  inside the window.
  """
  def make_fit(%__MODULE__{max_contents_len: mcl}, str) do
    str |> String.slice(0, mcl)
  end
end
