#!/bin/sh

#allow machine specific config overrides
if [ -r ~/.localrc-override ]; then
    # shellcheck disable=SC1090
    . ~/.localrc-override
fi
