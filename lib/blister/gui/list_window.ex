defmodule Bundle.GUI.ListWindow do

  defstruct [:win, :list, :offset, :curr_item_func]

  def create(rect, title_prefix, title, list, curr_item_func) do
    win, Window.create(rect, title_prefix, title)
    %__MODULE__{win: win, list: list, offset: 0, curr_item_func: curr_item_func}
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
        curr_index - visible_height + 1
      true ->
        lwin.offset
    end

    lwin.list[offset, w.visible_height]
    |> Enum.with_index
    |> Enum.each(fn {thing, i} ->
      :cecho.wmove(w.win, i+1, 1)
      if thing == curr_time, do: :cecho.attron(w.win, :cecho_consts.ceA_REVERSE)
      :cecho.waddstr(w.win, Window.make_fit(" #{thing.name} "))
      if thing == curr_time, do: :cecho.attroff(w.win, :cecho_consts.ceA_REVERSE)
    end)
    %{lwin | offset: offset}
  end
end
