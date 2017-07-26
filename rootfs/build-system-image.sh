#!/bin/sh
#
# This scripts takes a simpleimage and a kernel tarball, resizes the
# secondary partition and creates a rootfs inside it. Then extracts the
# Kernel tarball on top of it, resulting in a full Pine64 disk image.

OUT_IMAGE="$1"
OUT_BOOT_IMAGE="$2"
DISTRO="$3"
VARIANT="$4"
BUILD_ARCH="$5"
MODEL="$6"
shift 6

if [[ -z "$DISTRO" ]] || [[ -z "$VARIANT" ]] || [[ -z "$BUILD_ARCH" ]] || [[ -z "$MODEL" ]]; then
	echo "Usage: $0 <system.img> <boot.img> <distro> <variant: mate, i3 or minimal> <arch> <model> <packages...>"
    echo "Empty DISTRO, VARIANT, BUILD_ARCH or MODEL."
	exit 1
fi

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

BOOT_SIZE=100

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
BOOT_IMAGE="$(basename "$OUT_BOOT_IMAGE")"
echo "> Building in $TEMP ..."

cleanup() {
    local arg=$?
    echo "> Cleaning up ..."
    umount $TEMP/rootfs/boot/efi || true
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
dd if=/dev/zero of="$TEMP/$BOOT_IMAGE" bs=1M seek=$BOOT_SIZE count=0

# Make filesystem
mkfs.ext4 -L "linux-root" "$TEMP/$IMAGE" && tune2fs -o journal_data_writeback "$TEMP/$IMAGE"
mkfs.vfat -n "boot" -S 512 "$TEMP/$BOOT_IMAGE"

# Mount filesystem
mount "$TEMP/$IMAGE" "$TEMP/rootfs"
mkdir -p "$TEMP/rootfs/boot/efi"
mount "$TEMP/$BOOT_IMAGE" "$TEMP/rootfs/boot/efi"

# Create image
rootfs/make_rootfs.sh "$TEMP/rootfs" "$DISTRO" "$VARIANT" "$BUILD_ARCH" "$MODEL" "$@"

mv -v "$TEMP/$IMAGE" "$OUT_IMAGE"
mv -v "$TEMP/$BOOT_IMAGE" "$OUT_BOOT_IMAGE"

# Umount filesystem
fstrim "$TEMP/rootfs"
sync
