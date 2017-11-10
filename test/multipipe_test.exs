defmodule MultipipeTest do
  use ExUnit.Case
  import Multipipe

  doctest Multipipe

  test "greets the world" do
    assert "Hello" |> (param 1 :: _)
                   |> (param 2 :: "World")
                   |> (useparams Kernel.<>)
            == "HelloWorld"
  end

  test "parameters in any order" do
    assert "World" |> (param 2 :: _)
                   |> (param 1 :: "Hello")
                   |> (useparams Kernel.<>)
            == "HelloWorld"
  end

  test "strings together properly" do
    assert "World" |> String.reverse
                   |> (param 1 :: _)
                   |> (useparams String.reverse)
                   |> (param 2 :: _)
                   |> (param 1 :: "Hello")
                   |> (useparams Kernel.<>)
            == "HelloWorld"
  end

  def joiner(x1, x2, x3, x4) do x1 <> x2 <> x3 <> x4 end
  test "inserts into correct indices" do
    assert (param 2 :: "Two") |> (param 4 :: "Four")
                              |> (useparams joiner("One", "Three"))
           == "OneTwoThreeFour"
  end

end
