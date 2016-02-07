#!/bin/sh
#
# Simple script to create a U-Boot Android Kernel image suitable to be booted
# by boota command and copy it to a destination folder. The script also copies
# the dtb as compiled.  Usually the destination is a location which can be
# read while booting with U-Boot.
#

set -e

DEST="$1"

if [ -z "$DEST" ]; then
	echo "Usage: $0 <destination-folder>"
	exit 1
fi

LINUX="../linux"
# https://d-i.debian.org/daily-images/arm64/20160206-00:06/netboot/debian-installer/arm64/
INITRD="./initrd.gz"
MKBOOTIMG="../mkbootimg"
KERNEL="kernel.img"
DTB="pine64_plus.dtb"

# Clean up
rm -f "$DEST/$KERNEL"
rm -f "$DEST/$DTB"

# Create and copy
# Download https://android.googlesource.com/platform/system/core/+/master/mkbootimg/mkbootimg
$MKBOOTIMG --kernel "$LINUX/arch/arm64/boot/Image" --ramdisk "$INITRD" --base 0x40000000 --kernel_offset 0x01080000 --ramdisk_offset 0x20000000 --board Pine64 --pagesize 2048 -o "$DEST/$KERNEL"
cp -avf "$LINUX/arch/arm64/boot/dts/allwinner/$DTB" "$DEST/$DTB"
sync
