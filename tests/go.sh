#!/bin/bash

s="a=foo b=\"bar baz\" c=\$PATH d='omg wtf'
e=\"	lmao\"		f=huh"

function slice() {
    to_slice="$1"
    shift
    # Also add an ending boundary.
    boundaries=("$@" "$(("${#to_slice}" + 1))")
    lead=0

    for end in "${boundaries[@]}"; do
        ((len = end - lead))
        printf '%s\0' "${s:$lead:$len}"
        ((lead = end + 1)) # +1 = skip the separator
    done
}

in_sq_context=false
in_dq_context=false
esc=false
boundaries=()

for ((i=0; i < "${#s}"; i++)); do
    char="${s:$i:1}"

    if [[ "$esc" == "true" ]]; then # char is escaped, skipping.
        esc=false
        continue
    fi

    case "$char" in
        " "|"	"|"\n")
            if [[ "$in_sq_context" == "false" && "$in_dq_context" == "false" ]]; then
                # This is bare whitespace. Cut here.
                boundaries+=("$i")
            fi
            ;;
        "'")
            if [[ "$in_dq_context" == "true" ]]; then
                # This is a ' within doublequotes. Don't parse it.
                continue
            elif [[ "$in_sq_context" == "true" ]]; then
                # This is a closing quote.
                in_sq_context=false
            else
                # This is an opening quote.
                in_sq_context=true
            fi
            ;;
        '"')
            if [[ "$in_sq_context" == "true" ]]; then
                # This is a " within singlequotes. Don't parse it.
                continue
            elif [[ "$in_dq_context" == "true" ]]; then
                # This is a closing quote.
                in_dq_context=false
            else
                # This is an opening quote.
                in_dq_context=true
            fi
            ;;
    esac
done

echo "${boundaries[@]}"
mapfile -d '' kparams < <(slice "$s" "${boundaries[@]}")
echo "${kparams[0]}"
echo "${kparams[1]}"
echo "${kparams[2]}"
echo "${kparams[3]}"
echo "${kparams[4]}"
echo "${kparams[5]}"
echo "${kparams[6]}"
echo "${kparams[7]}"
echo "${kparams[8]}"
echo "${kparams[9]}"
