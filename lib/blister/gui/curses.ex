defmodule Blister.GUI.Curses do
  @min_modal_rows 20
  @min_modal_cols 60

  @behaviour Blister.GUI

  use GenServer
  require Logger
  alias Blister.Pack
  alias Blister.GUI.Curses.{Window, ListWindow, PatchWindow, TriggerWindow,
                            InfoWindow}
  alias Blister.GUI.Curses.Geometry, as: G

  # ================ Server ================

  def start_link do
    config_curses()
    windows = create_windows()
    GenServer.start_link(__MODULE__, windows, name: __MODULE__)
  end

  def init(state) do
    Logger.info("curses gui init")
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  # ================ API ================

  def update do
    Logger.debug("curses gui update calling genserver :refresh_all")
    GenServer.call(__MODULE__, :refresh_all)
    :ok
  end

  def help(file) do
    win = Window.create(G.help_rect, "Blister Help")
    w = win.win
    lines = file |> File.read! |> String.split("\n")

    draw_text_win(win, lines)
    :cecho.wrefresh(w)

    :cecho.getch
    :cecho.delwin(w)
    :cecho.touchwin(:cecho_consts.ceSTDSCR)
    :cecho.refresh
    :ok
  end

  def draw_text_win(%Window{win: w} = win, lines) do
    Window.draw(win)
    :cecho.wmove(w, 1, 2)
    lines |> Enum.map(fn line ->
      :cecho.waddstr(w, line |> to_char_list)
      {row, _} = :cecho.getyx(w)
      :cecho.wmove(w, row+1, 2)
    end)
    :ok
  end

  def getch do
    :cecho.getch
  end

  # TODO implement
  def prompt(_title, _prompt, default \\ nil) do
    # TODO use PromptWindow
    # pwin = Window
    # return {:ok, value} or nil
    {:ok, default}
  end

  def cleanup do
    GenServer.cast(__MODULE__, :cleanup)
    :ok
  end

  # ================ Handlers ================

  def handle_call(:refresh_all, _from, windows) do
    Logger.debug("gui handler refresh_all")
    windows = refresh_all(windows)
    {:reply, :ok, windows}
  end

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
    Logger.info("curses gui terminate")
  end

  # ================ Helpers ================

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

  defp config_curses do
    :application.start(:cecho)
    :cecho.cbreak
    :cecho.noecho
    :cecho.keypad(:cecho_consts.ceSTDSCR, true)
    :cecho.curs_set(:cecho_consts.ceCURS_INVISIBLE)
  end

  defp create_windows do
    windows = %{
      song_lists_win: ListWindow.create(G.song_lists_rect, nil, &Pack.song_list/0),
      song_list_win: ListWindow.create(G.song_list_rect, "Song List", &Pack.song/0),
      song_win: ListWindow.create(G.song_rect, "Song", &Pack.patch/0),
      patch_win: PatchWindow.create(G.patch_rect, "Patch"),
      message_win: Window.create(G.message_rect, nil),
      trigger_win: Window.create(G.trigger_rect, "Triggers"),
      info_win: InfoWindow.create(G.info_rect, "Song Notes")
    }

    draw_frame()
    :cecho.refresh

    # TODO
    # message_win.scrollok(false)

    windows
  end

  defp refresh_all(windows) do
    Logger.debug("refresh_all")
    windows = set_window_data(windows)
    windows = %{windows |
                song_lists_win: ListWindow.draw(windows.song_lists_win),
                song_list_win: ListWindow.draw(windows.song_list_win),
                song_win: ListWindow.draw(windows.song_win),
                patch_win: PatchWindow.draw(windows.patch_win),
                message_win: Window.draw(windows.message_win),
                trigger_win: TriggerWindow.draw(windows.trigger_win),
                info_win: InfoWindow.draw(windows.info_win)
               }

    :cecho.refresh
    windows |> Map.values |> Enum.map(&:cecho.wrefresh/1)
    # TODO for efficiency: replace the above with the below
    # ([stdscr] + wins).map(&:noutrefresh)
    # Curses.doupdate

    windows
  end

  defp set_window_data(windows) do
    Logger.debug("set window data")
    song = Pack.song
    patch = Pack.patch

result =
    %{windows |
      song_lists_win: ListWindow.set_contents(windows.song_lists_win, "Song Lists", Pack.song_lists),
      song_win: ListWindow.set_contents(windows.song_win,
                                        (if song, do: song.name, else: nil),
                                        (if song, do: song.patches, else: nil)),
      info_win: InfoWindow.set_text(windows.info_win, (if song, do: song.notes, else: nil)),
      patch_win: PatchWindow.set_patch(windows.patch_win, patch)
    }
    Logger.info("done setting window data")
result
  end
end
