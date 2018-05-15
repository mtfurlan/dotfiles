#!/bin/sh

xinput --disable $(xinput | sed -n 's/^.*TouchPad\W*id=\([0-9]*\).*$/\1/p')
