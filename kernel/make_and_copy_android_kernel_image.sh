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

BLOBS="../blobs"
LINUX="../linux"
MKBOOTIMG="../mkbootimg"
INITRD="./initrd.gz"

# Targets file names as loaded by U-Boot.
KERNEL="kernel.img"
DTB="sun50i-a64-pine64-plus.dtb"

if [ -n "$2" ]; then
	LINUX="$2"
fi

echo "Using Linux from $LINUX ..."

# Clean up
rm -vf "$DEST/$KERNEL"
rm -vf "$DEST/"*.dtb
rm -vf "$DEST/uEnv.txt"

# Create and copy Kernel
# Download https://android.googlesource.com/platform/system/core/+/master/mkbootimg/mkbootimg
echo -n "Creating $DEST/$KERNEL ..."
$MKBOOTIMG --kernel "$LINUX/arch/arm64/boot/Image" --ramdisk "$INITRD" --base 0x40000000 --kernel_offset 0x01080000 --ramdisk_offset 0x20000000 --board Pine64 --pagesize 2048 -o "$DEST/$KERNEL"
echo " OK"

# Create and copy binary device tree
if [ -d "$LINUX/arch/arm64/boot/dts/allwinner" ]; then
	# Seems to be mainline Kernel.
	if [ ! -e "$LINUX/arch/arm64/boot/dts/allwinner/$DTB" ]; then
		echo "Error: DTB not found at $LINUX/arch/arm64/boot/dts/allwinner/$DTB"
		exit 1
	fi
	echo -n "Copy "
	cp -av "$LINUX/arch/arm64/boot/dts/allwinner/"*.dtb "$DEST/"
else
	# Not found, use device tree from BSP.
	echo "Compiling device tree from $BLOBS/pine64.dts -> $DEST/$DTB"
	dtc -Odtb -o "$DEST/$DTB" "$BLOBS/pine64.dts"
fi

cat <<EOF > "$DEST/uEnv.txt"
fdt_filename=$DTB
console=tty0 console=ttyS0,115200n8 no_console_suspend
EOF

sync
echo "Done - boot files in $DEST"
