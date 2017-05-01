#!/bin/sh
#
# This scripts converts an existing uncompressed Pine64 disk image between the
# different Pine64 variants by replacing the bootloader (boot0 and U-Boot) while
# keeping all the rest intact.
#

set -e

DISKIMAGE="$1"
MODEL="$2"

if [ -z "$DISKIMAGE" -o -z "$MODEL" ]; then
	echo "Usage: $0 <disk or diskimage> <pine64|so|pinebook>"
	exit 1
fi

if [ "$MODEL" = "pine64" ]; then
    MODEL=""
fi
SUFFIX=""
if [ -n "$MODEL" ]; then
    SUFFIX="-$MODEL"
fi

# check image for boot0
boot0headerpos=$((8*1024+4))
boot0header=$(xxd -p -s $boot0headerpos -l 4 "$DISKIMAGE")
if [ "$boot0header" != "65474f4e" ]; then
    echo "Error: Target image has no eGON header, aborting!"
    exit 1
fi

ubootheaderpos=$((19096*1024+4))
ubootheader=$(xxd -p -s $ubootheaderpos -l 5 "$DISKIMAGE")
if [ "$ubootheader" != "75626f6f74" ]; then
    echo "Error: Target image has no uboot header, aborting!"
    exit 1
fi

set -x
(cd simpleimage && ./flash_boot0_only.sh "$DISKIMAGE" "../blobs/boot0$MODEL.bin")
(cd simpleimage && ./flash_u-boot_only.sh "$DISKIMAGE" "../build/u-boot-with-dtb$SUFFIX.bin")
set +x

echo "Done - image converted to $2"
