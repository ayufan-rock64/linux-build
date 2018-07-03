#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

BOARD=
if grep -qi rockpro64 /proc/device-tree/compatible || grep -qi rockpro64 /etc/flash-kernel/machine; then
    BOARD=rockpro64
elif grep -qi rock64 /proc/device-tree/compatible || grep -qi rock64 /etc/flash-kernel/machine; then
    BOARD=rock64
else
    exit "Unknown board."
    exit 1
fi

LOADER="/usr/lib/u-boot-${BOARD}/idbloader.img"
if [[ ! -f "$LOADER" ]]; then
    echo "Missing board bootloader image: $LOADER"
    exit 1
fi

echo "Doing this will overwrite bootloader stored on your boot device it might break your system."
echo "If this happens you will have to manually fix that outside of your Rock64."
echo "If you are booting from SPI. You have to use 'rock64_write_spi_flash.sh'."
echo ""

while true; do
    echo "Type YES to continue or Ctrl-C to abort."
    read CONFIRM
    if [[ "$CONFIRM" == "YES" ]]; then
        break
    fi
done

if ! debsums -s "u-boot-${BOARD}"; then
    echo "Verification of 'u-boot-${BOARD}' failed."
    echo "Your disk might have got corrupted."
    exit 1
fi

MNT_DEV=$(findmnt /boot/efi -n -o SOURCE)

case $MNT_DEV in
    /dev/mmcblk*p6|/dev/sd*p6)
        dd if=$LOADER of="${MNT_DEV/p6/p1}"
        ;;

    *)
        echo "Cannot detect boot device."
        echo "The bootloader can only be copied when booted from eMMC, SD or USB."
        exit 1
        ;;
esac

sync

echo Done.
