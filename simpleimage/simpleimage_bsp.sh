#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This scripts used boot0 binary blob extracted from the Pine64 Android image
# together with a compiled U-Boot from the BSP.
#
# U-Boot trees:
# - https://github.com/longsleep/u-boot-pine64/tree/lichee-dev-2014.07-fix-compile
#
# Build the U-Boot tree, patch the u-boot with a fex file and and put the
# created u-boot.fex into the same directory as this script. Also extract the
# boot0 binary blob from the Android image as released by Pine64.
#
# Extract boot0 from image:
#
# ```bash
# dd if="$IMAGE" bs=1k skip=8 count=32 of=boot0-android.bin
# ```

set -e

boot0="./boot0-android.bin"
uboot="./u-boot-with-dtb.bin"

boot0_position=8
uboot_position=19096
part_position=20480

out="./simpleimage-bsp.img"

dd if=/dev/zero bs=1M count=100 of="$out"
dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out"
dd if="$uboot" conv=notrunc bs=1k seek=$uboot_position of="$out"

# Add partition table
cat <<EOF | sfdisk -f "$out"
label: dos
unit: sectors

img1 : start=       40960, size=      102401, type=c
img2 : start=      143361, size=       61439, type=83
EOF

# Create file systems
dd if=/dev/zero bs=512 count=102401 of=${out}1
mkfs.vfat ${out}1
dd if=${out}1 conv=notrunc bs=512 seek=40960 of="$out"
rm ${out}1

dd if=/dev/zero bs=512 count=61439 of=${out}2
mkfs.ext4 ${out}2
dd if=${out}2 conv=notrunc bs=512 seek=143361 of="$out"
rm ${out}2

sync
