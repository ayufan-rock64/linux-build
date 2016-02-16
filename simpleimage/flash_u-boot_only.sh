#!/bin/sh
#
# Simple script to replace u-boot-with-dtb.bin in an existing image.
#

set -e

out="$1"

if [ -z "$out" ]; then
	echo "Usage: $0 /dev/sdX"
	exit 1
fi

uboot="../build/u-boot-with-dtb.bin"
uboot_position=19096  # KiB

pv "$uboot" | dd conv=notrunc bs=1k seek=$uboot_position of="$out"

sync
