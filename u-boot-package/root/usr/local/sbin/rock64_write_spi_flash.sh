#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

if ! which nandwrite &>/dev/null; then
    echo "Install mtd-utils with 'apt-get install mtd-utils'"
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
if ! -f "$LOADER"; then
    echo "Missing board bootloader image: $LOADER"
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

if ! debsums -s "u-boot-${BOARD}"; then
    echo "Verification of 'u-boot-${BOARD}' failed."
    echo "Your disk might have got corrupted."
    exit 1
fi

MNT_DEV=$(findmnt /boot/efi -n -o SOURCE)

write_nand() {
    if ! MTD=$(grep \"$1\" /proc/mtd | cut -d: -f1); then
        echo "$1 partition on MTD is not found"
        return 1
    fi

    echo "Writing /dev/$MTD with content of $2"
    flash_erase "/dev/$MTD" 0 0
    nandwrite "/dev/$MTD" < "$2"
}

write_nand loader "$LOADER"

echo Done.
