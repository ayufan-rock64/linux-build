#!/bin/sh
#
# Simple script to create a U-Boot Android Kernel image suitable to be booted
# by boota command and copy it to a destination folder. The script also copies
# the dtb as compiled.  Usually the destination
# should be used for booting with U-Boot.
#

set -e

DEST="$1"

if [ -z "$DEST" ]; then
	echo "Usage: $0 <destination-folder>"
	exit 1
fi

LINUX="../linux"
MKBOOTIMG="../mkbootimg"
KERNEL="kernel.img"
DTB="pine64_plus.dtb"

# Download https://android.googlesource.com/platform/system/core/+/master/mkbootimg/mkbootimg
$MKBOOTIMG --kernel ../linux/arch/arm64/boot/Image --base 0x40000000 --kernel_offset 0x01080000 --board Pine64 --pagesize 2048 -o $DEST/$KERNEL
dtc -Idtb -Odtb -R4 -o$DEST/$DTB -R4 ../linux/arch/arm64/boot/dts/allwinner/$DTB
