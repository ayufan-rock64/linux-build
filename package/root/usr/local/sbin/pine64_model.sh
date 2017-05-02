#!/bin/sh

set -e

MODEL="pine64"
# Detect Pinebook.
if [ -e "/proc/device-tree/soc@01c00000/lcd0@01c0c000/lcd_driver_name" \
     -a "$(cat /proc/device-tree/soc\@01c00000/lcd0\@01c0c000/lcd_driver_name)" = "anx9804_panel" ]; then
    MODEL="pinebook"
fi
echo "$MODEL"
