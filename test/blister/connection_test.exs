defmodule Blister.ConnectionTest do
  use ExUnit.Case
  doctest Blister.Connection
  alias Blister.Connection
  alias Blister.Connection.CIO
  alias Blister.Predicates, as: P
  alias Blister.Consts, as: C

  setup do
    conn = %Connection{
      input: %CIO{sym: :in_sym, chan: 4},
      output: %CIO{sym: :out_sym, chan: 4},
      filter: fn _, {b0, b1, b2} = msg ->
        if P.note?(msg), do: {b0, b1, max(0, b2-1)}, else: msg end,
      zone: (64..75),
      xpose: 12}
    {:ok, %{conn: conn}}
  end

  test "passes through non-channel messages", context do
    msgs = Connection.process(context[:conn], [{C.tune_request, 0, 0}])
    |> Enum.to_list
    assert msgs == [{C.tune_request, 0, 0}]
  end

  test "passes through correct channel and range and munges", context do
    assert context[:conn].xpose == 12
    msgs = Connection.process(context[:conn], [{C.note_on + 4, 65, 118}])
    |> Enum.to_list
    assert msgs == [{C.note_on + 4, 77, 117}]
  end

  test "filters out different channels", context do
    msgs = Connection.process(context[:conn], [{C.note_on, 65, 118}])
    |> Enum.to_list
    assert msgs == []
  end

  test "filters out notes outside zone", context do
    msgs = Connection.process(context[:conn], [{C.note_on, 13, 118}])
    |> Enum.to_list
    assert msgs == []
  end
end
