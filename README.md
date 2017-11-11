# Multipipe

Macros to augment the default pipe, allowing multiple parameter pipes and pipes
into arbitrary inputs.

## Usage

Clone or copy the library into your project and `import Multipipe` in any module
that needs it.

## Examples

Our first example of using multiple parameter pipes sets the first parameter as
"Hello", the second as "World", and pipes them into the string concatenation
function `Kernel.<>`.

    iex> param(1 :: "Hello") |> param(2 :: "World")
    ...>                     |> useparams(Kernel.<>)
    "HelloWorld"

The order of specifying the parameters doesn't matter:

    iex> param(2 :: "World") |> param(1 :: "Hello")
    ...>                     |> useparams(Kernel.<>)
    "HelloWorld"

Once you start collecting parameters with `params` you must either continue
piping into further `params` statements to collect more parameters, or into a
`useparams` statement to use them.

If you want to use the output of a pipe as a parameter, piping into a parameter
statement is also supported by using an underscore:

    iex> "olleH" |> String.reverse
    ...>         |> param(1 :: _)
    ...>         |> param(2 :: "World")
    ...>         |> useparams(Kernel.<>)
    "HelloWorld"

Partial parameters are also supported, as long as the other parameters are
supplied in the function call. This allows for piping into arbitrary inputs:

    iex> param(1 :: "Hello") |> useparams(Kernel.<>("World"))
    "HelloWorld"

    iex> param(2 :: "Hello") |> useparams(Kernel.<>("World"))
    "WorldHello"

## Further information, but you probably shouldn't use the module this way.
What I said earlier about having to terminate parameter collection with a `useparams`
statement is not entirely accurate. The result of the `param` statements is a map
`%{index => value}` mapping indices to values, so you can technically do whatever
you want with this.

In fact, the `param` macro can be used to construct arbitrary maps:

    iex> player = param(:first_name :: "Turd")
    ...>            |> param(:last_name :: "Ferguson")
    ...>            |> param(:score :: 0)
    %{first_name: "Turd", last_name: "Ferguson", score: 0}

You can only pass maps with integer keys into `useparams`, however.
