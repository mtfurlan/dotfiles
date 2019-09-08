#!/bin/sh

xinput --disable $(xinput | sed -n 's/^.*TouchPad\W*id=\([0-9]*\).*$/\1/p')
# If mouse stops working on thinkpad, this has helped: https://bugzilla.redhat.com/show_bug.cgi?id=1228566
# echo -n rescan | sudo tee /sys/devices/platform/i8042/serio1/drvctl
