#!/bin/sh
#
# This scripts takes a simpleimage and a kernel tarball, resizes the
# secondary partition and creates a rootfs inside it. Then extracts the
# Kernel tarball on top of it, resulting in a full Pine64 disk image.

OUT_IMAGE="$1"
SIMPLEIMAGE="$2"
KERNELTAR="$3"
PACKAGEDEB="$4"
DISTRO="$5"
MODEL="$6"
VARIANT="$7"
SIZE="${8:-3650}"
BUILD_ARCH="$9"
if [[ -z "$MODEL" ]]; then
  MODEL="rock64"
fi
if [[ -z "$BUILD_ARCH" ]]; then
  BUILD_ARCH="arm64"
fi
export MODEL
export BUILD_ARCH

if [ -z "$VARIANT" ]; then
	echo "Usage: $0 <result.img> <simpleimage.img.xz> <kernel.tar.xz> <package.deb> [distro] [model] [variant: mate, i3, empty] [size (MiB)] [build_arch]"
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
[[ -n "$KERNELTAR" ]] && KERNELTAR=$(readlink -f "$KERNELTAR")

PWD=$(readlink -f .)
TEMP=$(mktemp -p $PWD -d -t "$MODEL-build-XXXXXXXXXX")
IMAGE="$(basename "$OUT_IMAGE")"
echo "> Building in $TEMP ..."

cleanup() {
    local arg=$?
    echo "> Cleaning up ..."
    umount $TEMP/image/* || true
    umount "$TEMP/image" || true
    rm -r "$TEMP"
    exit $arg
}
trap cleanup EXIT

set -ex

# Create folders
mkdir -p "$TEMP/rootfs" "$TEMP/boot" "$TEMP/image"

# Create image
./make_rootfs.sh "$TEMP/rootfs" "$KERNELTAR" "$PACKAGEDEB" "$DISTRO" "$TEMP/boot" "$MODEL" "$VARIANT"

# Create
dd if=/dev/zero of="$TEMP/$IMAGE" bs=1M seek=$(($SIZE-1)) count=1

# Make filesystem
mkfs.ext4 "$TEMP/$IMAGE"

# Mount filesystem
mount "$TEMP/$IMAGE" "$TEMP/image"

# Copy all files
sudo cp -rfp $TEMP/rootfs/*  "$TEMP/image"

# Umount filesystem
umount "$TEMP/image"

sleep 2

mv -v "$TEMP/$IMAGE" "$OUT_IMAGE"
