defmodule Blister.GUI do
  @min_modal_rows 20
  @min_modal_cols 60

  use GenServer
  require Logger
  alias Blister.GUI.{Window, Geometry}

  # ================ Server ================

  def start_link do
    :application.start(:cecho)
    :cecho.cbreak
    :cecho.noecho
    :cecho.keypad(:cecho_consts.ceSTDSCR, true)
    :cecho.curs_set(:cecho_consts.ceCURS_INVISIBLE)
    draw_frame
    :cecho.refresh
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    Logger.info("gui init")
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  # ================ API ================

  def refresh, do: :cecho.refresh

  def status(msg), do: status(msg, false)

  def status(nil, _) do
    draw_frame
  end
  def status("", _) do
    draw_frame
  end
  def status(msg, true) do
    status(msg, false)
  end
  def status(msg, false) do
    {max_row, _} = :cecho.getmaxyx
    :cecho.move(max_row-1, 0)
    clrtoeol
    msg |> to_char_list |> :cecho.addstr
  end

  def help(file) do
    win = Geometry.help_rect |> Window.create(nil, "Blister Help")
    lines = file |> File.read! |> String.split("\n")
    modal_display(win, lines)
  end

  @doc """
  Display a titled dialog that displays `lines`. Wait for a keypress, then
  erase the dialog. Return the keypress.
  """
  def modal_display(%Window{win: w} = win, lines) do
    Window.draw(win)
    :cecho.wmove(w, 1, 2)
    lines |> Enum.map(fn line ->
      :cecho.waddstr(w, line |> to_char_list)
      {row, _} = :cecho.getyx(w)
      :cecho.wmove(w, row+1, 2)
    end)
    :cecho.wrefresh(w)

    ch = :cecho.getch
    :cecho.delwin(w)
    :cecho.touchwin(:cecho_consts.ceSTDSCR)
    :cecho.refresh
    ch
  end

  def getch do
    :cecho.getch
  end

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
  end

  # ================ Handlers ================

  def handle_cast(:cleanup, state) do
    Logger.info("gui cleanup")
    {max_row, _} = :cecho.getmaxyx
    :cecho.move(max_row-1, 0)
    :cecho.curs_set(:cecho_consts.ceCURS_NORMAL)
    :cecho.echo
    :cecho.refresh
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    Logger.info("gui terminate")
  end

  # ================ Helpers ================

  defp clrtoeol do
    {_, max_col} = :cecho.getmaxyx
    {row, col} = :cecho.getyx
    do_clrtoeol(col, max_col)
    :cecho.move(row, col)
  end

  defp do_clrtoeol(c, mc) when c > mc do
  end
  defp do_clrtoeol(c, mc) do
    :cecho.addch(?\s)
    do_clrtoeol(c+1, mc)
  end

  defp draw_frame do
    :cecho.box(:cecho_consts.ceSTDSCR, :cecho_consts.ceACS_VLINE,
      :cecho_consts.ceACS_HLINE)
    title(:cecho_consts.ceSTDSCR, "Blister")
  end

  defp title(win, title) do
    {_, max_col} = :cecho.getmaxyx(win)
    :cecho.wmove(win, 0, trunc((max_col - (String.length(title)+4)) / 2))
    :cecho.waddch(win, ?\s)
    :cecho.attron(win, :cecho_consts.ceA_REVERSE)
    :cecho.waddch(win, ?\s)
    :cecho.waddstr(win, title |> to_char_list)
    :cecho.waddch(win, ?\s)
    :cecho.attroff(win, :cecho_consts.ceA_REVERSE)
    :cecho.waddch(win, ?\s)
  end

end
