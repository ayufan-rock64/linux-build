#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
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

if ! debsums -s u-boot-rock64; then
    echo "Verification of 'u-boot-rock64' failed."
    echo "Your disk might have got corrupted."
    exit 1
fi

MNT_DEV=$(findmnt /boot/efi -n -o SOURCE)

case $MNT_DEV in
    /dev/mmcblk*p6|/dev/sd*p6)
        dd if=/usr/lib/u-boot-rock64/idbloader.img of="${MNT_DEV/p6/p1}"
        ;;

    *)
        echo "Cannot detect boot device."
        echo "The bootloader can only be copied when booted from eMMC, SD or USB."
        exit 1
        ;;
esac

sync

echo Done.
