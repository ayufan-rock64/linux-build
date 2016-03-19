#!/bin/sh
#
# Simple script to put the Kernel image into a destination folder
# to be booted. The script also copies the a initrd and the conmpiled device
# tree. Usually the destination is a location which can be read while booting
# with U-Boot.
#
# Use this script to populate the first partition of disk images created with
# the simpleimage script of this project.
#

set -e

DEST="$1"

if [ -z "$DEST" ]; then
	echo "Usage: $0 <destination-folder> [linux-folder]"
	exit 1
fi

BLOBS="../blobs"
LINUX="../linux"
INITRD="./initrd.gz"

# Targets file names as loaded by U-Boot.
SUBFOLDER="pine64"
KERNEL="$SUBFOLDER/Image"
INITRD_IMG="initrd.img"

if [ "$DEST" = "-" ]; then
	DEST="../build"
fi

if [ -n "$2" ]; then
	LINUX="$2"
fi

echo "Using Linux from $LINUX ..."

# Clean up
mkdir -p "$DEST/$SUBFOLDER"
rm -vf "$DEST/$KERNEL"
rm -vf "$DEST/"*.dtb
rm -vf "$DEST/uEnv.txt"

# Create and copy Kernel
echo -n "Copying Kernel ..."
cp -vf "$LINUX/arch/arm64/boot/Image" "$DEST/$KERNEL"
echo " OK"

# Copy initrd
echo -n "Copying initrd ..."
cp -vf "$INITRD" "$DEST/$INITRD_IMG"
echo " OK"

# Create and copy binary device tree
if [ -d "$LINUX/arch/arm64/boot/dts/allwinner" ]; then
	# Seems to be mainline Kernel.
	if [ ! -e "$LINUX/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dtb" ]; then
		echo "Error: DTB not found at $LINUX/arch/arm64/boot/dts/allwinner/"
		exit 1
	fi
	echo -n "Copy "
	cp -v "$LINUX/arch/arm64/boot/dts/allwinner/"*.dtb "$DEST/$SUBFOLDER/"
else
	# Not found, use device tree from BSP.
	echo "Compiling device tree from $BLOBS/pine64.dts"
	dtc -Odtb -o "$DEST/$SUBFOLDER/sun50i-a64-pine64-plus.dtb" "$BLOBS/pine64.dts"
	echo "Compiling device tree from $BLOBS/pine64noplus.dts"
	dtc -Odtb -o "$DEST/$SUBFOLDER/sun50i-a64-pine64.dtb" "$BLOBS/pine64noplus.dts"
fi

cat <<EOF > "$DEST/uEnv.txt"
console=tty0 console=ttyS0,115200n8 no_console_suspend
kernel_filename=$KERNEL
initrd_filename=$INITRD_IMG
EOF

sync
echo "Done - boot files in $DEST"
