#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

echo "Doing this will overwrite data stored on SPI Flash"
echo "  and it will require that you use eMMC or SD"
echo "  as your boot device."
echo ""

while true; do
    echo "Type YES to continue or Ctrl-C to abort."
    read CONFIRM
    if [[ "$CONFIRM" == "YES" ]]; then
        break
    fi
done

case $(findmnt / -n -o SOURCE) in
    /dev/mmcblk0p7)
        dd if=/dev/mmcblk0p1 of=/dev/mtd1

    /dev/mmcblk1p7)
        dd if=/dev/mmcblk1p1 of=/dev/mtd1
        ;;

    *)
        echo "Cannot detect boot device."
        echo "The bootloader can only be copied when booted from eMMC or SD."
        exit 1
        ;;
esac

echo Done.
