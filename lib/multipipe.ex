defmodule Multipipe do
  @moduledoc """
  Macros to augment the default pipe, allowing multiple parameter pipes and pipes
  into arbitrary inputs.

  Absolutely nothing is altered with the standard pipe.

  Our first example of using multiple parameter pipes sets the first parameter as
  "Hello", the second as "World", and pipes them into the string concatenation
  function `Kernel.<>`.

      iex> (param 1 :: "Hello") |> (param 2 :: "World")
      ...>                      |> (useparams Kernel.<>)
      "HelloWorld"

  The order of specifying the parameters doesn't matter:

      iex> (param 2 :: "World") |> (param 1 :: "Hello")
      ...>                      |> (useparams Kernel.<>)
      "HelloWorld"

  Once you start collecting parameters with `param` you must either continue
  piping into further `param` statements to collect more parameters, or into a
  `useparams` statement to use them.

  If you want to use the output of a pipe (or any other value that can can be
  piped) as a parameter, piping into a parameter statement is also supported by
  using an underscore:

      iex> "olleH" |> String.reverse
      ...>         |> (param 1 :: _)
      ...>         |> (param 2 :: "World")
      ...>         |> (useparams Kernel.<>)
      "HelloWorld"

  Partial parameters are also supported, as long as the other parameters are
  supplied in the function call. This allows for piping into arbitrary inputs:

      iex> (param 1 :: "Hello") |> (useparams Kernel.<>("World"))
      "HelloWorld"

      iex> (param 2 :: "Hello") |> (useparams Kernel.<>("World"))
      "WorldHello"
  """

  defp expand(x) do
    x |> Macro.postwalk(fn(x) -> x |> Macro.expand(__ENV__) end)
  end

  @doc """
  Collects parameters, which are applied with `useparams`.

  The syntax is `(param index :: value)` to use `value` for the parameter with
  index `index`.

  Parameters are collected by piping them into each other, and must terminate by
  piping into a `useparams` statement.

  See the module docs for usage examples.
  """
  defmacro param(params \\ {:%{}, [], []}, expr)

  # If a value is piped into a param statement with an underscore, replace the
  # underscore with the value.
  defmacro param(value, {:::, _, [index, {:_, _, _}]}) do
    quote do
      param(unquote({:::, [], [index, value]}))
    end
  end

  # Otherwise, it's assumed the value piped into the statement is already a set
  # of parameters, which are maps. In this case, add the new `index => value`
  # to the map.
  defmacro param({:%{}, context, list}, {:::, _, [index, value]}) do
    quote do
      unquote({:%{}, context, list ++ [{index, value}]})
    end
  end

  # For expanding the macro. Is there a way to avoid needing this?
  defmacro param({:param, _, _} = x, y) do
    quote do
      param(unquote(x |> expand), unquote(y |> expand))
    end
  end


  @doc """
  Applies a set of parameters collected with `param` statements to a function.

  See the module docs for usage examples.
  """
  # If the list of parameters is empty, return the function statement.
  defmacro useparams({:%{}, _, []}, func) do
    func
  end

  # Otherwise, find the lowest index parameter and add it to the function call.
  defmacro useparams({:%{}, _, list}, partial) do
    {index, value} = list |> Enum.min
    partial = Macro.pipe(value, partial, index - 1)
    quote do
      useparams(unquote({:%{}, nil, list -- [{index, value}]}), unquote(partial))
    end
  end

  # Expand the param macros so we can access the parameters as maps instead of
  # nested ASTs.
  defmacro useparams({:param, _, _} = x, partial) do
    quote do
      useparams(unquote(x |> expand), unquote(partial))
    end
  end
end
