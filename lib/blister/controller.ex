defmodule Blister.Controller do
  use GenServer
  require Logger
  alias Blister.Pack

  @helpfile "priv/help.txt"
  @f1 :cecho_consts.ceKEY_F(1)
  @esc :cecho_consts.ceKEY_ESC
  @up :cecho_consts.ceKEY_UP
  @down :cecho_consts.ceKEY_DOWN
  @left :cecho_consts.ceKEY_LEFT
  @right :cecho_consts.ceKEY_RIGHT

  defmodule State do
    defstruct [:gui, :looper]
  end

  # ================ API ================

  def start_link(gui) do
    GenServer.start_link(__MODULE__, %State{gui: gui}, name: __MODULE__)
  end

  def init(state) do
    Logger.info("controller init")
    {:ok, state}
  end

  def start_command_loop, do: GenServer.call(__MODULE__, :start_command_loop)

  def next_patch, do: Pack.next_patch
  def prev_patch, do: Pack.prev_patch
  def next_song, do: Pack.next_song
  def prev_song, do: Pack.prev_song
  def help, do: GenServer.call(__MODULE__, :help)

  def quit do
    Logger.info("controller quitting")
    GenServer.call(__MODULE__, :gui_cleanup)
    Blister.Supervisor.quit
  end

  # ================ GenServer ================

  def handle_call(:start_command_loop, _from, state) do
    Logger.debug("controller handler :start_command_loop")
    # TODO supervise the command loop
    state = %{state | looper: spawn(fn -> command_loop(state.gui) end)}
    Logger.debug("state = #{inspect state}")
    {:reply, nil, state}
  end

  def handle_call(:help, _from, state) do
    state.gui.help(@helpfile)
    {:reply, nil, state}
  end

  def handle_call(:gui_cleanup, _from, state) do
    state.gui.cleanup
    {:reply, nil, state}
  end

  # ================ Helpers ================

  def command_loop(gui) do
    Logger.debug("command_loop")
    gui.update
    Logger.debug("command_loop back from GUI.update")
    c = gui.getch
    if c > 0 do
      Logger.debug("key pressed: #{[c]} (#{c})")
    end
    case c do
      ?? -> help
      ?h -> help
      @f1 -> help
      ?q -> quit
      ?j -> next_patch
      @down -> next_patch
      ?\s -> next_patch
      ?k -> prev_patch
      @up -> prev_patch
      ?n -> next_song
      @right -> next_song
      ?p -> prev_song
      @left -> prev_song
      ?g -> :ok                 # go to song
      ?t -> :ok                 # go to song list
      ?e -> :ok                 # edit
      ?r -> :ok                 # reload
      @esc -> :ok               # panic
      ?l -> :ok                 # load
      ?s -> :ok                 # save
      # TODO use message window
      # ch when ch > 0 ->
      #   GUI.status("#{[ch]}: huh? (press \"h\" for help)")
      _ -> :ok
      # TODO resize
    end
    command_loop(gui)
  end
end
