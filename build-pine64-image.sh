#!/bin/sh
#
# This scripts takes a simpleimage and a kernel tarball, resizes the
# secondary partition and creates a rootfs inside it. Then extracts the
# Kernel tarball on top of it, resulting in a full Pine64 disk image.
#
# Latest stuff can be found at the following locations:
# -  https://www.stdin.xyz/downloads/people/longsleep/pine64-images/simpleimage-pine64-latest.img.xz
# -  https://www.stdin.xyz/downloads/people/longsleep/pine64-images/linux/linux-pine64-latest.tar.xz"

OUT_IMAGE="$1"
SIMPLEIMAGE="$2"
KERNELTAR="$3"
PACKAGEDEB="$4"
DISTRO="$5"
MODEL="$6"
VARIANT="$7"
SIZE="${8:-3650}"
if [[ -z "$MODEL" ]]; then
  MODEL="pine64"
fi
export MODEL

if [ -z "$SIMPLEIMAGE" -o -z "$KERNELTAR" ]; then
	echo "Usage: $0 <result.img> <simpleimage.img.xz> <kernel.tar.xz> <package.deb> [distro] [model] [variant: mate, i3, empty] [size (MiB)]"
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

if [ -z "$DISTRO" ]; then
	DISTRO="xenial"
fi

SIMPLEIMAGE=$(readlink -f "$SIMPLEIMAGE")
KERNELTAR=$(readlink -f "$KERNELTAR")

PWD=$(readlink -f .)
TEMP=$(mktemp -p $PWD -d -t "$MODEL-build-XXXXXXXXXX")
IMAGE="$(basename "$OUT_IMAGE")"
OUT_IMAGE="$(readlink -f "$IMAGE")"
echo "> Building in $TEMP ..."

cleanup() {
    local arg=$?
    echo "> Cleaning up ..."
    umount "$TEMP/boot" || true
    umount $TEMP/rootfs/* || true
    umount "$TEMP/rootfs" || true
    kpartx -sd "$TEMP/$IMAGE" || true
    kpartx -sd "$OUT_IMAGE" || true
    rmdir "$TEMP/boot"
    rmdir "$TEMP/rootfs"
    rm -r "$TEMP"
    exit $arg
}
trap cleanup EXIT

set -ex

# Unpack
unxz -k --stdout "$SIMPLEIMAGE" > "$TEMP/$IMAGE"
# Enlarge
dd if=/dev/zero bs=1M seek=$(($SIZE-1)) count=1 of="$TEMP/$IMAGE"
# Resize
echo ",+,L" | sfdisk -N 2 -L -uS --force "$TEMP/$IMAGE"

# Device
mkdir "$TEMP/boot"
mkdir "$TEMP/rootfs"
DEVICE=$(losetup --show --find "$TEMP/$IMAGE")
DEVICENAME=$(basename $DEVICE)
echo "> Device is $DEVICE ..."
kpartx -avs $DEVICE

# Resize filesystem
resize2fs /dev/mapper/${DEVICENAME}p2 || true

# Mount
mount /dev/mapper/${DEVICENAME}p1 "$TEMP/boot"
mount /dev/mapper/${DEVICENAME}p2 "$TEMP/rootfs"

sleep 2
(cd simpleimage && sh ./make_rootfs.sh "$TEMP/rootfs" "$KERNELTAR" "$PACKAGEDEB" "$DISTRO" "$TEMP/boot" "$MODEL" "$VARIANT")

mv -v "$TEMP/$IMAGE" "$OUT_IMAGE"

fstrim "$TEMP/rootfs"
