defmodule Blister.GUI.Curses.PatchWindow do

  defstruct [:win, :patch]

  alias Blister.GUI.Curses.Window

  def create(r, title_prefix, title \\ nil) do
    %__MODULE__{win: Window.create(r, title_prefix, title), patch: nil}
  end

  def set_patch(pwin, patch) do
    title_prefix = if patch, do: patch.name, else: nil
    win = Window.set_title(pwin.win, title_prefix)
    %{pwin | win: win, patch: patch}
  end

  def draw(%__MODULE__{win: w, patch: patch} = pwin) do
    Window.draw(w)
    :cecho.wmove(w, 1, 1)
    draw_headers(w)
    if patch do
      patch.connections
      |> Enum.slice(0, w.visible_height)
      |> Enum.with_index
      |> Enum.map(fn {connection, i} ->
        :cecho.wmove(w, i+2, 1)
        draw_connection(w, connection)
      end)
    end
    pwin
  end

  def draw_headers(w) do
    :cecho.attron(w, :cecho_consts.ceA_REVERSE)
    str = " Input          Chan | Output         Chan | Prog | Zone      | Xpose | Filter"
    {height, _, _, _} = w.r
    str <> (List.duplicate(' ', height - 2 - String.length(str)) |> to_string)
    :cecho.waddstr(w, str)
    :cecho.attroff(w, :cecho_consts.ceA_REVERSE)
  end

  def draw_connection(w, connection) do
    formats = [
      " ~-16s",
      (if connection.input_chan, do: " ~2d", else: "  "),
      " ~-16s",
      (if connection.output_chan, do: " ~2d", else: "  "),
      (if connection.pc_prog, do: " ~3d |", else: "      |"),
      (if connection.zone, do: " ~3d - ~3d |", else: "           |"),
      (cond do
        connection.xpose < 0 -> " ~4d |"
        connection.xpose > 0 -> "  ~3d |"
        true -> "       |"
      end),
      " ~s"
    ]
    data = [
      connection.input_name || "",
      (if connection.input_chan, do: connection.input_chan + 1, else: nil),
      connection.output_name || "",
      (if connection.output_chan, do: "%2d", else: "  "),
      (if connection.pc_prog, do: connection.pc_prog, else: nil),
      (if connection.zone, do: connection.zone.first, else: nil),
      (if connection.zone, do: connection.zone.last, else: nil),
      connection.xpose,
      filter_string(connection.filter)
    ]

    charlist = :io.format(
      formats |> Enum.join("") |> to_char_list,
      data |> Enum.filter(fn d -> d == nil end) |> Enum.map(&(to_char_list(&1)))
    )
    str = charlist |> to_string
    :cecho.waddstr(w, Window.make_fit(w, str))
  end

  defp filter_string(nil), do: ""
  # TODO
  defp filter_string(filter), do: IO.inspect(filter) # DEBUG
  # def filter_string(filter)
  #   filter.to_s.gsub(/\s*#.*/, '').gsub(/\n\s*/, "; ")
  # end
end
