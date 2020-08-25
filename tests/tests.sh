#!/bin/bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function run() {
    "$TESTSHELL" "$HERE/../k_params" "$@"
}

function error() {
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "${RED}[$TESTSHELL] $*${NC}" >&2
}
function info() {
    GRN='\033[0;32m'
    NC='\033[0m'
    echo -e "${GRN}[$TESTSHELL] $*${NC}" >&2
}
function warn() {
    YLW='\033[0;33m'
    NC='\033[0m'
    echo -e "${YLW}[$TESTSHELL] $*${NC}" >&2
}

function check() {
    rc=0
    if ! have="$(run "$1")"; then
        error "Failed check in ${FUNCNAME[1]}; k_params '$1' exited with status $?"
        FAILURES+=("${FUNCNAME[1]}")
        rc=1
    fi

    if [[ "$have" != "$2" ]]; then
        error "Failed check in ${FUNCNAME[1]}; k_params '$1' = '$have', want '$2'"
        FAILURES+=("${FUNCNAME[1]}")
        rc=1
    else
        info "${FUNCNAME[1]}; check k_params '$1' ✓"
    fi
    return "$rc"
}

function check_with_default() {
    rc=0
    if ! have="$(run "$1" "$2")"; then
        error "Failed check_with_default in ${FUNCNAME[1]}; k_params '$1' '$2' exited with status $?"
        FAILURES+=("${FUNCNAME[1]}")
        rc=1
    fi

    if [[ "$have" != "$3" ]]; then
        error "Failed check_with_default in ${FUNCNAME[1]}; k_params '$1' '$2' = '$have', want '$3'"
        FAILURES+=("${FUNCNAME[1]}")
        rc=1
    else
        info "${FUNCNAME[1]}; check_with_default k_params '$1' '$2' ✓"
    fi
    return "$rc"
}

function wantfail() {
    if have="$(run "$1")"; then
        error "Failed wantfail in ${FUNCNAME[1]}; '$*' = '$have'"
        FAILURES+=("${FUNCNAME[1]}")
    else
        info "${FUNCNAME[1]}; wantfail '$*' ✓"
    fi
}

FAILURES=()

function test_unquoted() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    check rootflags "rw"
    check mount.usrflags "ro"
}

function test_quoted() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    check sshkey "ssh-rsa blahblah"
    check hostname "node0"
    check singlequotes "abc"
}

function test_defaults() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    wantfail doesnotexist
    check_with_default doesnotexist "lmao" "lmao"
}

function test_usage() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/flatcar_cmdline.txt"

    if have="$(run 2>&1)"; then
        error "Failed in ${FUNCNAME[0]}; k_params exited with status $?"
        FAILURES+=("${FUNCNAME[0]}")
    fi
    if ! grep -q "Usage:" <<< "$have"; then
        error "Failed in ${FUNCNAME[0]}; k_params lacks 'Usage:'; have '$have'"
        FAILURES+=("${FUNCNAME[0]}")
    fi
}

function test_danger() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/danger.txt"

    check foo "*"
    check bar '`echo evalling this is a bad vuln`'
    check dolla '$PATH'
}

function test_escaping() {
    export TESTONLY_ALTERNATIVE_CMDLINE="$HERE/the_great_escape.txt"

    check a '"'
    check b "'"
    check c '\'
    check d 'a\b'
}


UNHEALTHY=

function runtests() {
    TESTSHELL="$1"

    if ! which "$TESTSHELL" >/dev/null 2>/dev/null; then
        warn "skipping tests for this shell since we can't find it in PATH"
        return
    fi

    shift
    if [[ "$#" -gt 0 ]]; then
        info "Running just the following tests: $*"
        CASES=("$@")
    else
        CASES=(test_unquoted test_quoted test_defaults test_usage test_danger test_escaping)
    fi

    for c in "${CASES[@]}"; do "$c"; done

    if [[ "${#FAILURES[@]}" -gt 0 ]]; then
        f="$(printf "%s\n" "${FAILURES[@]}" | sort -u | xargs printf "    - %s\n")"
        error "\nEncountered failures on the following:\n$f"
        UNHEALTHY=yes
    fi
}

for shell in bash dash ash posh ksh zsh; do runtests "$shell" "$@"; done
if [[ -n "$UNHEALTHY" ]]; then
    exit 1
fi
