#!/bin/sh
#
# Simple script to create a U-Boot with all the additional parts which are
# required to be accepted by th A64 boot0.
#
# This script requires build variants and tools from several other sources.
# See the variable definitions below. When all files can be found, a U-Boot
# file is created which can be loaded by A64 boot0 just fine.

set -e

# Blobs as provided in the BSP
BLOBS="../blobs"
# https://github.com/longsleep/u-boot-pine64/tree/pine64-hacks
UBOOT="../u-boot-pine64"
# https://github.com/longsleep/arm-trusted-firmware-pine64
TRUSTED_FIRMWARE="../arm-trusted-firmware-pine64"
# https://github.com/longsleep/sunxi-pack-tools
SUNXI_PACK_TOOLS="../sunxi-pack-tools/bin"

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    echo "Usage: $0 [<pine64|pinebook>] [<trusted-firmware-build>]"
    exit 1
fi
MODEL="$1"
if [ "$MODEL" = "pine64" ]; then
    MODEL=""
fi
SUFFIX=""
if [ -n "$MODEL" ]; then
    SUFFIX="-$MODEL"
fi

TRUSTED_FIRMWARE_BUILD="$2"
if [ -z "$TRUSTED_FIRMWARE_BUILD" ]; then
    TRUSTED_FIRMWARE_BUILD="release"
fi

BUILD="../build"
mkdir -p $BUILD

echo "ATF build: $TRUSTED_FIRMWARE_BUILD"
cp -avf $TRUSTED_FIRMWARE/build/sun50iw1p1/$TRUSTED_FIRMWARE_BUILD/bl31.bin $BUILD
cp -avf $UBOOT/u-boot-sun50iw1p1.bin $BUILD/u-boot.bin
cp -avf $BLOBS/scp.bin $BUILD
cp -avf $BLOBS/sys_config.fex $BUILD

# build binary device tree
DT="pine64$MODEL"
echo "Device tree: $DT"
dtc -Odtb -o $BUILD/$DT.dtb $BLOBS/$DT.dts

unix2dos $BUILD/sys_config.fex
$SUNXI_PACK_TOOLS/script $BUILD/sys_config.fex

# merge_uboot.exe u-boot.bin infile outfile mode[secmonitor|secos|scp]
$SUNXI_PACK_TOOLS/merge_uboot $BUILD/u-boot.bin $BUILD/bl31.bin $BUILD/u-boot-merged$SUFFIX.bin secmonitor
$SUNXI_PACK_TOOLS/merge_uboot $BUILD/u-boot-merged$SUFFIX.bin $BUILD/scp.bin $BUILD/u-boot-merged2$SUFFIX.bin scp

# update_fdt.exe u-boot.bin xxx.dtb output_file.bin
$SUNXI_PACK_TOOLS/update_uboot_fdt $BUILD/u-boot-merged2$SUFFIX.bin $BUILD/$DT.dtb $BUILD/u-boot-with-dtb$SUFFIX.bin

# Add fex file to u-boot so it actually is accepted by boot0.
$SUNXI_PACK_TOOLS/update_uboot $BUILD/u-boot-with-dtb$SUFFIX.bin $BUILD/sys_config.bin

echo "Done - created $BUILD/u-boot-with-dtb$SUFFIX.bin"
