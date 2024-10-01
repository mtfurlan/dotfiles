#!/bin/sh

if [ -r ~/.localrc ]; then
    # shellcheck disable=SC1090
    . ~/.localrc
fi
