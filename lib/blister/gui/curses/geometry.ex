# Defines positions and sizes of windows. Rects contain {height, width, top,
# left}.
defmodule Blister.GUI.Curses.Geometry do

  def song_list_rect do
    g = geometry()
    {g.sl_height, g.top_width, 0, 0}
  end

  def song_rect do
    g = geometry()
    {g.sl_height, g.top_width, 0, g.top_width}
  end

  def song_lists_rect do
    g = geometry()
    {g.sls_height, g.top_width, g.sl_height, 0}
  end

  def trigger_rect do
    g = geometry()
    {g.sls_height, g.top_width, g.sl_height, g.top_width}
  end

  def patch_rect do
    g = geometry()
    {g.bot_height, g.max_col, g.top_height, 0}
  end

  def message_rect do
    g = geometry()
    {1, g.max_col, g.max_row-1, 0}
  end

  def info_rect do
    g = geometry()
    {g.top_height, g.info_width, 0, g.info_left}
  end

  def help_rect do
    g = geometry()
    {g.max_row - 6, g.max_col - 6, 3, 3}
  end

  defp geometry do
    {max_row, max_col} = :cecho.getmaxyx

    top_height = trunc((max_row - 1) * 2 / 3)
    bot_height = (max_row - 1) - top_height
    top_width = trunc(max_col / 3)

    sls_height = trunc(top_height / 3)
    sl_height = top_height - sls_height

    info_width = max_col - (top_width * 2)
    info_left = top_width * 2

    %{max_row: max_row, max_col: max_col,
      top_height: top_height, bot_height: bot_height, top_width: top_width,
      sls_height: sls_height, sl_height: sl_height,
      info_width: info_width,
      info_left: info_left}
  end
end
