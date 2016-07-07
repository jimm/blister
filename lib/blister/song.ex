defmodule Blister.Song do
  defstruct name: "Unnamed",
    patches: [],
    notes: ""

  def create(name) do
    song = %__MODULE__{name: name}
    Blister.Pack.add_song(song)
    song
  end
end
