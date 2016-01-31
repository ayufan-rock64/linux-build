#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This scripts used boot0 binary blob and binary U-Boot extracted from the
# Pine64 Android image.
#
# Extract boot0 from image:
#
# ```bash
# dd if="$IMAGE" bs=1k skip=8 count=32 of=boot0-android.bin
# ```
# Extract U-Boot from image:
#
# ```bash
# dd if="$IMAGE" bs=1k skip=19096 count=20480 of=u-boot-android.bin
# ```

set -e

boot0="./boot0-android.bin"
uboot="./u-boot-android.bin"

boot0_position=8
uboot_position=19096

out="./simpleimage-android.img"

dd if=/dev/zero bs=1M count=25 of="$out"
dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out"
dd if="$uboot" conv=notrunc bs=1k seek=$uboot_position of="$out"
sync
