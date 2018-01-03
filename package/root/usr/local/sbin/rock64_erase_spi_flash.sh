#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

if ! which flash_erase &>/dev/null; then
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

if ! MTD=$(grep \"loader\" /proc/mtd | cut -d: -f1); then
    echo "loader partition on MTD is not found"
    return 1
fi

flash_erase "/dev/$MTD"

echo Done.
