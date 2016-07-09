defmodule Blister.Controller do
  use GenServer
  require Logger
  alias Blister.{Input, GUI, MIDI, Pack}

  @helpfile "priv/help.txt"
  @f1 :cecho_consts.ceKEY_F(1)
  @esc :cecho_consts.ceKEY_ESC
  @up :cecho_consts.ceKEY_UP
  @down :cecho_consts.ceKEY_DOWN
  @left :cecho_consts.ceKEY_LEFT
  @right :cecho_consts.ceKEY_RIGHT

  defmodule State do
    defstruct [:looper]
  end

  # ================ API ================

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
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
  def info, do: GenServer.call(__MODULE__, :info)

  def quit do
    Logger.info("controller quitting")
    Blister.Supervisor.quit
  end

  # ================ GenServer ================

  def handle_call(:start_command_loop, _from, _) do
    Logger.debug("controller handler :start_command_loop")
    # TODO supervise the command loop
    state = %State{looper: spawn(&command_loop/0)}
    Logger.debug("state = #{inspect state}")
    {:reply, nil, state}
  end

  def handle_call(:next_patch, _from, state) do
    # TODO
    {:reply, nil, state}
  end

  def handle_call(:prev_patch, _from, state) do
    # TODO
    {:reply, nil, state}
  end

  def handle_call(:next_song, _from, state) do
    # TODO
    {:reply, nil, state}
  end

  def handle_call(:prev_song, _from, state) do
    # TODO
    {:reply, nil, state}
  end

  def handle_call(:help, _from, state) do
    GUI.help(@helpfile)
    {:reply, nil, state}
  end

  def handle_call(:info, _from, state) do
    input_strs = MIDI.inputs |> Enum.map(&Input.name/1) |> numbered_list
    output_strs = MIDI.outputs |> Enum.map(&(&1.name)) |> numbered_list
    lines = ["Inputs"] ++ input_strs ++
      ["", "Outputs"] ++ output_strs
    GUI.modal_display("Info", lines)
    {:reply, nil, state}
  end

  # ================ Helpers ================

  def command_loop do
    Logger.debug("command_loop")
    GUI.refresh
    Logger.debug("command_loop back from GUI.refresh")
    c = GUI.getch
    if c > 0 do
      Logger.debug("key pressed: #{[c]} (#{c})")
    end
    case c do
      ?? -> help
      ?h -> help
      @f1 -> help
      ?i -> info
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
    command_loop
  end

  defp numbered_list(list) do
    list
    |> Enum.with_index
    |> Enum.map(fn {str, idx} -> "#{idx}: #{str}" end)
  end
end
