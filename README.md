# k_params

Extracts values from /proc/cmdline.

## Usage

`$ k_params PARAM_NAME [DEFAULT_VALUE]`

## Requirements

* `bash` 4+ (we use associative arrays, but I could reconsider if someone cares)

## Caveats

The current implemtation `eval`s /proc/cmdline, so we refuse to process that if
there's a `$` in there to prevent corruption and env leakage.
