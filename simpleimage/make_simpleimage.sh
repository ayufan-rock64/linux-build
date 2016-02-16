#!/bin/sh
#
# Simple script to create a disk image which boots to U-Boot on Pine64.
#
# This script uses boot0 binary blob (as extracted from the Pine64 Android
# image) together with a correctly prefixed U-Boot and A DOS partition table
# to create a bootable SDcard image for the Pine64. If a Kernel and DTB is
# found in ../kernel, it is added as well.
#
# U-Boot tree:
# - https://github.com/longsleep/u-boot-pine64/tree/pine64-hacks
#
# Build the U-Boot tree and assemble it with ATF, SCP and FEX and put the
# resulting u-boot-with-dtb.bin file into the ../build directory. The
# u-boot-postprocess script provides an easy way to do all that.
#

set -e

out="$1"
disk_size="$2"

if [ -z "$out" ]; then
	echo "Usage: $0 <image-file.img> [disk size in MiB]"
	exit 1
fi

if [ -z "$disk_size" ]; then
	disk_size=100 #MiB
fi

if [ "$disk_size" -lt 60 ]; then
	echo "Disk size must be at least 60 MiB"
	exit 2
fi

echo "Creating image $out of size $disk_size MiB ..."

boot0="../blobs/boot0.bin"
uboot="../build/u-boot-with-dtb.bin"
kernel="../kernel"

boot0_position=8      # KiB
uboot_position=19096  # KiB
part_position=20480   # KiB
boot_size=50          # MiB

set -x

dd if=/dev/zero bs=1M count=$disk_size of="$out"
dd if="$boot0" conv=notrunc bs=1k seek=$boot0_position of="$out"
dd if="$uboot" conv=notrunc bs=1k seek=$uboot_position of="$out"

# Add partition table
cat <<EOF | sfdisk -q -f "$out"
label: dos
unit: sectors
start=$((part_position*2)), size=${boot_size}M, type=c
start=$((part_position*2 + boot_size*1024*2)), type=83
EOF

# Create boot file system (VFAT)
dd if=/dev/zero bs=1M count=${boot_size} of=${out}1
mkfs.vfat ${out}1
# Add boot stuff if there.
if [ -e "${kernel}/kernel.img" -a -e "${kernel}/pine64_plus.dtb" ]; then
	mcopy -i ${out}1 ${kernel}/kernel.img ::kernel.img
	mcopy -i ${out}1 ${kernel}/*.dtb ::
fi
dd if=${out}1 conv=notrunc bs=1k seek=${part_position} of="$out"
rm -f ${out}1

# Create additional ext4 file system.
dd if=/dev/zero bs=1M count=$((disk_size-boot_size-part_position/1024)) of=${out}2
mkfs.ext4 ${out}2
dd if=${out}2 conv=notrunc bs=1k seek=$((part_position+boot_size*1024)) of="$out"
rm -f ${out}2

sync

echo "Done - image created: $out"
