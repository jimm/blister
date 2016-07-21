defmodule Blister.DSLTest do
  use ExUnit.Case
  alias Blister.{DSL, Pack}

  test "loads an empty setup" do
    assert DSL.load_string("%{}") == %Pack{}
  end
end
