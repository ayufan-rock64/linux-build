#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This script uses a U-Boot tree from the sunxi project. Currently this is
# work in progress.
#
# U-Boot trees:
# - https://github.com/ssvb/u-boot-sunxi/tree/20160126-wip-a64-experimental
#
# Build the U-Boot tree and put the created u-boot-sunxi-with-spl.bin into
# the same directory as this script.

set -e

boot0="./u-boot-sunxi-with-spl.bin"

boot0_position=8

out="./simpleimage-sunxi.img"

dd if=/dev/zero bs=1M count=1 of="$out"
dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out"
sync
