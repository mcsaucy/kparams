#!/bin/bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function run() {
    bash "$HERE/../k_params" "$@"
}

function error() {
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "${RED}$*${NC}" >&2
}

function check() {
    if [[ "$1" != "$2" ]]; then
        error "Failed check in ${FUNCNAME[1]}; have '$1', want '$2'"
    fi
    FAILURES+=("${FUNCNAME[1]}")
}

FAILURES=()

function test_unquoted() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    check "$(run rootflags)" "ro"
}

function test_quoted() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    check "$(run sshkey)" "ssh-rsa blahblah"
    check "$(run hostname)" "node0"
}


CASES=(test_unquoted test_quoted)
for c in "${CASES[@]}"; do "$c"; done

if [[ "${#FAILURES[@]}" > 0 ]]; then
    f="$(printf "%s\n" "${FAILURES[@]}" | sort -u | xargs printf "    - %s\n")"
    error "\nEncountered failures on the following:\n$f"
    exit 1
fi
