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

MNT_DEV=$(findmnt / -n -o SOURCE)

write_nand() {
    if ! MTD=$(grep \"$1\" /proc/mtd | cut -d: -f1); then
        echo "$1 partition on MTD is not found"
        return 1
    fi

    echo "Writing /dev/$MTD with content of $2"
    flash_erase "/dev/$MTD" 0 0
    nandwrite "/dev/$MTD" < "$2"
}

case $MNT_DEV in
    /dev/mmcblk0p7)
        write_nand loader /dev/mmcblk0p1
        ;;

    /dev/mmcblk1p7)
        write_nand loader /dev/mmcblk1p1
        ;;

    /dev/sd*p7)
        write_nand loader "${MNT_DEV/p7/p1}"
        ;;

    *)
        echo "Cannot detect boot device."
        echo "The bootloader can only be copied when booted from eMMC, SD or USB."
        exit 1
        ;;
esac

echo Done.
