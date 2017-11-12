defmodule Multipipe do
  @moduledoc """
  Macros to augment the default pipe, allowing multiple parameter pipes and
  pipes into arbitrary inputs.

  Our first example of using multiple parameter pipes sets the first parameter
  as "Hello", the second as "World", and pipes them into the string
  concatenation function `Kernel.<>`.

      iex> param(1, "Hello") |> param(2, "World")
      ...>                   |> useparams(Kernel.<>)
      "HelloWorld"

  The order of specifying the parameters doesn't matter:

      iex> param(2, "World") |> param(1, "Hello")
      ...>                   |> useparams(Kernel.<>)
      "HelloWorld"

  The statement `param(i, value)` means "use `value` as parameter number `i`". The
  syntax must be given as `param(i, value)` or, as we'll see below, `value |> param(i, _)`.

  Once you start collecting parameters with `param` you must either continue
  piping into further `param` statements to collect more parameters, or into a
  `useparams` statement to use them.

  If you want to use the output of a pipe (or any other value that can can be
  piped) as a parameter, piping into a parameter statement is supported by using
  an underscore:

      iex> "olleH" |> String.reverse
      ...>         |> param(1, _)
      ...>         |> param(2, "World")
      ...>         |> useparams(Kernel.<>)
      "HelloWorld"

  Partial parameters are also supported, as long as the other parameters are
  supplied in the function call. This allows for piping into arbitrary inputs:

      iex> param(1, "Hello") |> useparams(Kernel.<>("World"))
      "HelloWorld"

      iex> param(2, "Hello") |> useparams(Kernel.<>("World"))
      "WorldHello"
  """

  defp expand(x) do
    x |> Macro.postwalk(fn(x) -> x |> Macro.expand(__ENV__) end)
  end

  @doc """
  Collects parameters, which are applied with `useparams`.

  The usage syntax is
      `param(index, value)`
  to create a new set of parameters with the given value for the given index, or
      `param(params, index, value)` to take an existing collection of parameters
  and set the given index to `value`.

  It is intended to be used with the Elixir pipe, to allow multiple parameter
  pipes in conjunction with `useparams`:
      iex> param(1, "Hello") |> param(2, "World") |> useparams(Kernel.<>)
      "HelloWorld"

  To allow parameter collection to start in the middle of a pipeline, there is
      `param(value, index, _)`
  provided as a shorthand for `param(index, value)`. For instance:
      iex> "olleH" |> String.reverse
      ...>         |> param(1, _)
      ...>         |> param(2, "World")
      ...>         |> useparams(Kernel.<>)
      "HelloWorld"

  Parameters collected by `param` should always be terminated by piping them into
  a `useparams` statement.

  See the module docs for further usage examples.
  """
  defmacro param(params \\ {:%{}, [], []}, index, value)

  # If a value is piped into a param statement with an underscore, replace the
  # underscore with the value.
  defmacro param(value, index, {:_, _, _}) do
    quote do
      param(unquote(index), unquote(value))
    end
  end

  # Otherwise, it's assumed the value piped into the statement is already a set
  # of parameters, which is a map. In this case, add the new `index => value`
  # to the map, deleting any value already associated to `index` if it exists.
  defmacro param({:%{}, meta, list}, index, value) do
    list = List.keydelete(list, index, 0)
    quote do
      unquote({:%{}, meta, list ++ [{index, value}]})
    end
  end

  # For expanding the macro. Is there a way to avoid needing this?
  defmacro param({:param, _, _} = x, y, z) do
    quote do
      param(unquote(x |> expand), unquote(y |> expand), unquote(z |> expand))
    end
  end


  @doc """
  Applies a set of parameters collected with `param` statements to a function.

  The usage syntax is
      `useparams(params, function_call)`
  where `params` is a collection of parameters assembled by `param` statements,
  and `function_call` is a (possibly partially applied) call to a function, that
  is, anything you could normally pipe into with the default Elixir pipe `|>`.

  It is intended to be used with the Elixir pipe, for terminating a series of
  `param` statements.

  See the docs for `Multipipe.param/3` and the module docs for usage examples.
  """
  # If the list of parameters is empty, return the function statement.
  defmacro useparams({:%{}, _, []}, func) do
    func
  end

  # Otherwise, find the lowest index parameter and add it to the function call.
  defmacro useparams({:%{}, meta, list}, partial) do
    {index, value} = list |> Enum.min
    partial = Macro.pipe(value, partial, index - 1)
    quote do
      useparams(unquote({:%{}, meta, list -- [{index, value}]}), unquote(partial))
    end
  end

  # Expand the param macros so we can access the parameters as maps instead of
  # nested ASTs.
  defmacro useparams({:param, _, _} = x, partial) do
    quote do
      useparams(unquote(x |> expand), unquote(partial))
    end
  end

  @doc """
  Pipe the input value into a specified parameter of a function call.

  Example usage:

      # function call: String.contains?("foobar", "bar")
      iex> "bar" |> as_param(2, String.contains?("foobar"))
      true
  """
  defmacro as_param(value, index, func) do
    quote do
      unquote(Macro.pipe(value, func, index - 1))
    end
  end
end
