#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This scripts uses boot0 binary blob (as extracted from the Pine64 Android
# image) together with a correctly prefixed U-Boot, and A DOS partition table
# to create a bootable SDcard image for the Pine64.
#
# U-Boot trees:
# - https://github.com/longsleep/u-boot-pine64/tree/lichee-dev-2014.07-fix-compile
#
# Build the U-Boot tree, patch the U-boot with a fex file and and put the
# created u-boot.fex into the same directory as this script. Also extract the
# boot0 binary blob from the Android image as released by Pine64 and put it
# into the same directory.
#
# This is how to extract boot0 from an existing image:
#
# ```bash
# dd if="$IMAGE" bs=1k skip=8 count=32 of=boot0-android.bin
# ```
#

set -e

boot0="./boot0-android.bin"
uboot="./u-boot-with-dtb.bin"

boot0_position=8
uboot_position=19096
part_position=20480
disk_size=100 # MiB
boot_size=50  # MiB

out="./simpleimage.img"

dd if=/dev/zero bs=1M count=$disk_size of="$out"
dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out"
dd if="$uboot" conv=notrunc bs=1k seek=$uboot_position of="$out"

# Add partition table
cat <<EOF | sfdisk -f "$out"
label: dos
unit: sectors
start=$((part_position*2)), size=${boot_size}M, type=c
start=$((part_position*2 + boot_size*1024*2)), type=83
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
