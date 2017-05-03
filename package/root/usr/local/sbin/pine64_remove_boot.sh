#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

echo "Pine A64/Pinebook boot remover!"
echo "(C) 2017. Kamil Trzciński (https://ayufan.eu)."
echo ""
echo "The purpose of this script is to remove boot0 and make the disk unbootable."
echo ""

usage() {
    echo "Usage:"
    echo "$ $0 [disk]"
    echo ""
    echo "If no disk is specified the /dev/mmcblk0 will be used."
    exit 1
}

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
    usage
fi

DISK="${1-/dev/mmcblk0}"

echo "Doing this will make the "$DISK" unbootable."

while true; do
    echo "Type YES to continue or Ctrl-C to abort."
    read CONFIRM
    if [[ "$CONFIRM" == "YES" ]]; then
        break
    fi
done

echo ""
dd conv=notrunc bs=1k seek=8 count=32 oflag=direct if=/dev/zero of="$DISK"

echo "Done."
