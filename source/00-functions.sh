#!/bin/sh

setTitle() {
    printf '\033]0;%s\007' "$@"
}

exists() {
    command -v "$@" >/dev/null
}
