defmodule MultipipeTest do
  use ExUnit.Case
  import Multipipe

  doctest Multipipe

  test "greets the world" do
    assert "Hello" |> param(1, _)
                   |> param(2, "World")
                   |> useparams(Kernel.<>)
            == "HelloWorld"
  end

  test "parameters in any order" do
    assert "World" |> param(2, _)
                   |> param(1, "Hello")
                   |> useparams(Kernel.<>)
            == "HelloWorld"
  end

  test "strings together properly" do
    assert "World" |> String.reverse
                   |> param(1, _)
                   |> useparams(String.reverse)
                   |> param(2, _)
                   |> param(1, "Hello")
                   |> useparams(Kernel.<>)
            == "HelloWorld"
  end

  def joiner(x1, x2, x3, x4) do x1 <> x2 <> x3 <> x4 end
  test "inserts into correct indices" do
    assert param(2, "Two") |> param(4, "Four")
                           |> useparams(joiner("One", "Three"))
           == "OneTwoThreeFour"
  end

  test "as_param works to pipe into different parameters" do
    assert %{:a => "ok"} |> as_param(1, Map.get(:a, :error)) == "ok"
    assert %{:b => "ok"} |> as_param(1, Map.get(:a, :error)) == :error
    assert :a |> as_param(2, Map.get(%{:a => "ok"}, :error)) == "ok"
    assert :b |> as_param(2, Map.get(%{:a => "ok"}, :error)) == :error
    assert :error |> as_param(3, Map.get(%{:a => "ok"}, :b)) == :error
    assert nil |> as_param(3, Map.get(%{:a => "ok"}, :b)) == nil
  end

end
