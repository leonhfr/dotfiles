#!/bin/bash

p_header() {
    printf "\n$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}

p_log() {
    printf "$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}

p_success() {
    printf "$(tput setaf 64)✓ %s$(tput sgr0)\n" "$@"
}

p_error() {
    printf "$(tput setaf 1)x %s$(tput sgr0)\n" "$@"
}

p_warn() {
    printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$@"
}

type_exists() {
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}