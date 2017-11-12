# Multipipe

Macros to augment the default pipe, allowing multiple parameter pipes and pipes
into arbitrary inputs.

This module provides the pair of macros `param` and `useparams` to allow multiple
parameters to be collected and then passed to a function through the standard
Elixir pipe.

It also provides the macro `as_param` that redirects the standard pipe to another
input index.

## Usage

Clone or copy the library into your project and `import Multipipe` in any module
that needs it.

## Examples

#### `param` and `useparams`

Our first example of using multiple parameter pipes sets the first parameter as
"Hello", the second as "World", and pipes them into the string concatenation
function `Kernel.<>`.

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

If you want to use the output of a pipe as a parameter, piping into a parameter
statement is supported by replacing the value with an underscore:

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

#### `as_param`
If you only want to redirect a single input to a different parameter and find
`param`/`useparams` too wordy, `as_param` can be used instead.

For instance, this example pipes a key value into a call to `Map.get/2`,
redirecting the pipe to the second parameter:

    iex> :a |> as_param(2, Map.get(%{:a => "ok"}))
    "ok"

This can be a handy shortcut, to avoid writing extraneous helper functions or
helper macros to reorder the inputs.

## Further information, but you probably shouldn't use the module this way.
What I said earlier about having to terminate parameter collection with a `useparams`
statement is not entirely accurate. The result of the `param` statements is a map
of `index => value` pairs mapping indices to values, so you can technically do
whatever you want with this.

`param` is just a macro version of `Map.put/3` and can be used to construct
arbitrary maps at compile time:

    iex> player = param(:first_name, "Turd")
    ...>            |> param(:last_name, "Ferguson")
    ...>            |> param(:score, 0)
    %{first_name: "Turd", last_name: "Ferguson", score: 0}

You can only pass maps with integer keys that are defined at compile time into
`useparams`, however.
