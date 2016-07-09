defmodule Blister.GUI.ListWindow do

  alias Blister.GUI.Window
  require Logger

  defstruct [:win, :list, :offset, :curr_item_func]

  @doc """
  `curr_item_func` is a function that is called to obtain the current item
  so we can highlight it.
  """
  def create(rect, title_prefix, curr_item_func) do
    win = Window.create(rect, title_prefix)
    %__MODULE__{win: win, offset: 0, curr_item_func: curr_item_func}
  end

  def set_contents(lwin, title, list) do
    %{lwin | win: %{lwin.win | title: title}, list: list, offset: 0}
  end

  def draw(lwin) do
    w = lwin.win
    Window.draw(w)

    curr_item = lwin.curr_item_func.()
    curr_index = lwin.list |> Enum.find_index(fn x -> x == curr_item end)

    offset = cond do
      curr_index < lwin.offset ->
        curr_index
      curr_index >= lwin.offset + w.visible_height ->
        curr_index - w.visible_height + 1
      true ->
        lwin.offset
    end

    lwin.list
    |> Enum.slice(offset, w.visible_height)
    |> Enum.with_index
    |> Enum.each(fn {thing, i} ->
      :cecho.wmove(w.win, i+1, 1)
      if thing == curr_item, do: :cecho.attron(w.win, :cecho_consts.ceA_REVERSE)
      :cecho.waddstr(w.win, Window.make_fit(w, " #{thing.name} "))
      if thing == curr_item, do: :cecho.attroff(w.win, :cecho_consts.ceA_REVERSE)
    end)
    %{lwin | offset: offset}
  end
end
