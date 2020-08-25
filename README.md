# k_params

Extracts values from /proc/cmdline. Handles bare and quoted parameters.

Check out `tests/*.txt` to see examples of what we can extract.

## Usage

`$ k_params PARAM_NAME [DEFAULT_VALUE]`

## Requirements

* `bash` 4+ (we use associative arrays, but I could reconsider if someone cares)
