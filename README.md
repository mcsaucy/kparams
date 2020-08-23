# k_params

Extracts values from /proc/cmdline. Handles bare and quoted parameters.

## Usage

`$ k_params PARAM_NAME [DEFAULT_VALUE]`


## Requirements

* `bash` 4+ (we use associative arrays, but I could reconsider if someone cares)

## Caveats

We're presently unable to handle certain escapes within parameters. For example:
`foo="bar: \"baz\""` will look like `\"baz\"` when queried, rather than `"baz"`.
It'll take another parsing pass to make that work, which will get fixed if I
care enough.
