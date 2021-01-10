# kparams

Extracts kernel parameter values from /proc/cmdline. Handles bare and quoted
parameters.

See [kernel.org's docs on kernel parameters](
https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html) for
more information. While the docs mention using double-quotes to protect values
with spaces, we also recognize single-quotes and certain escape sequences to
support things like `quoted="\"value\""`.

Check out `tests/*.txt` to see examples of what we can extract.

## Usage

`$ k_params PARAM_NAME [DEFAULT_VALUE]`

## Requirements

* A POSIX-compliant shell, or ZSH
