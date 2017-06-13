#!/bin/sh
#
# This scripts takes a simpleimage and a kernel tarball, resizes the
# secondary partition and creates a rootfs inside it. Then extracts the
# Kernel tarball on top of it, resulting in a full Pine64 disk image.

OUT_IMAGE="$1"
DISTRO="$2"
VARIANT="$3"
BUILD_ARCH="$4"
MODEL="$5"
SIZE="$6"
shift 6

export MODEL
export BUILD_ARCH

if [ -z "$SIZE" ]; then
	echo "Usage: $0 <result.img> <distro> <variant: mate, i3 or minimal> <arch> <model> <size (MiB)> <packages...>"
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
    umount $TEMP/rootfs/* || true
    umount "$TEMP/rootfs" || true
    rm -r "$TEMP"
    exit $arg
}
trap cleanup EXIT

set -ex

# Create folders
mkdir -p "$TEMP/rootfs"

# Create
dd if=/dev/zero of="$TEMP/$IMAGE" bs=1M seek=$SIZE count=0

# Make filesystem
mkfs.ext4 "$TEMP/$IMAGE"

# Mount filesystem
mount "$TEMP/$IMAGE" "$TEMP/rootfs"

# Create image
./make_rootfs.sh "$TEMP/rootfs" "$DISTRO" "$VARIANT" "$BUILD_ARCH" "$MODEL" "$@"

mv -v "$TEMP/$IMAGE" "$OUT_IMAGE"

# Umount filesystem
fstrim "$TEMP/rootfs"
sync
