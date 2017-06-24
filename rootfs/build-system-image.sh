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
shift 5

if [[ -z "$DISTRO" ]] || [[ -z "$VARIANT" ]] || [[ -z "$BUILD_ARCH" ]] || [[ -z "$MODEL" ]]; then
	echo "Usage: $0 <result.img> <distro> <variant: mate, i3 or minimal> <arch> <model> <packages...>"
    echo "Empty DISTRO, VARIANT, BUILD_ARCH or MODEL."
	exit 1
fi

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

case "$VARIANT" in
    minimal)
        SIZE=1024
        ;;

    i3)
        SIZE=2048
        ;;

    mate)
        SIZE=5120
        ;;

    openmediavault)
        SIZE=2048
        ;;

    *)
        echo "Unknown VARIANT: $VARIANT"
        exit 1
        ;;
esac

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
rootfs/make_rootfs.sh "$TEMP/rootfs" "$DISTRO" "$VARIANT" "$BUILD_ARCH" "$MODEL" "$@"

mv -v "$TEMP/$IMAGE" "$OUT_IMAGE"

# Umount filesystem
fstrim "$TEMP/rootfs"
sync
