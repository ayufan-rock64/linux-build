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
	echo "Usage: $0 <destination-folder> [linux-folder]"
	exit 1
fi

LINUX="../linux"
INITRD="./initrd.gz"
MKBOOTIMG="../mkbootimg"
KERNEL="kernel.img"
DTB="pine64_plus.dtb"

if [ -n "$2" ]; then
	LINUX="$2"
fi

echo "Using Linux from $LINUX ..."

# Clean up
rm -vf "$DEST/$KERNEL"
rm -vf "$DEST/"*.dtb

# Create and copy Kernel
# Download https://android.googlesource.com/platform/system/core/+/master/mkbootimg/mkbootimg
echo -n "Creating $DEST/$KERNEL ..."
$MKBOOTIMG --kernel "$LINUX/arch/arm64/boot/Image" --ramdisk "$INITRD" --base 0x40000000 --kernel_offset 0x01080000 --ramdisk_offset 0x20000000 --board Pine64 --pagesize 2048 -o "$DEST/$KERNEL"
echo " OK"

# Create and copy binary device tree
echo -n "Copy "
if [ -d "$LINUX/arch/arm64/boot/dts/allwinner" ]; then
	# Seems to be mainline Kernel.
	if [ ! -e "$LINUX/arch/arm64/boot/dts/allwinner/$DTB" ]; then
		echo "Error: DTB not found at $LINUX/arch/arm64/boot/dts/allwinner/$DTB"
		exit 1
	fi
	cp -av "$LINUX/arch/arm64/boot/dts/allwinner/"*.dtb "$DEST/"
else
	# Not found, use BSP provided dtb.
	cp -avf "../blobs/sunxi.dtb" "$DEST/$DTB"
fi

sync
echo "Done - boot files in $DEST"
