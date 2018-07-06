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
	echo "Usage: $0 <disk.img> <distro> <variant: mate, i3 or minimal> <arch> <model> <packages...>"
    echo "Empty DISTRO, VARIANT, BUILD_ARCH or MODEL."
	exit 1
fi

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

case "$VARIANT" in
    minimal)
        SIZE=2046
        ;;

    i3)
        SIZE=2560
        ;;

    mate)
        SIZE=5120
        ;;

    lxde)
        SIZE=3072
        ;;

    openmediavault)
        SIZE=2048
        ;;

    containers)
        SIZE=2560
        ;;

    *)
        echo "Unknown VARIANT: $VARIANT"
        exit 1
        ;;
esac

PWD=$(readlink -f .)
TEMP=$(mktemp -p $PWD -d -t "$MODEL-build-XXXXXXXXXX")
echo "> Building in $TEMP ..."

cleanup() {
    echo "> Cleaning up ..."
    umount "$TEMP/rootfs/boot/efi" || true
    umount "$TEMP/rootfs/"* || true
    umount "$TEMP/rootfs" || true
    kpartx -d "${LODEV}" || true
    losetup -d "${LODEV}" || true
    rm -rf "$TEMP"
}
trap cleanup EXIT

TEMP_IMAGE="${TEMP}/disk.img"

set -ex

# Create
dd if=/dev/zero of="$TEMP_IMAGE" bs=1M seek=$((SIZE-1)) count=0

# Create partitions
echo Updating GPT...
parted -s "${TEMP_IMAGE}" mklabel gpt
parted -s "${TEMP_IMAGE}" unit s mkpart loader1      64 8063      # 4MB
parted -s "${TEMP_IMAGE}" unit s mkpart reserved1    8064 8191    # 4MB
parted -s "${TEMP_IMAGE}" unit s mkpart reserved2    8192 16383   # 4MB
parted -s "${TEMP_IMAGE}" unit s mkpart loader2      16384 24575  # 4MB
parted -s "${TEMP_IMAGE}" unit s mkpart atf          24576 32767  # 4MB
parted -s "${TEMP_IMAGE}" unit s mkpart boot fat16   32768 262143 # 128MB
parted -s "${TEMP_IMAGE}" unit s mkpart root ext4    262144 100%  # rest
parted -s "${TEMP_IMAGE}" set 7 legacy_boot on

# Assign lodevice
LODEV=$(losetup -f --show "${TEMP_IMAGE}")

# Map path from /dev/loop to /dev/mapper/loop
LODEVMAPPER="${LODEV/\/dev\/loop/\/dev\/mapper\/loop}"

# Assign partitions
kpartx -a "$LODEV"

# Make filesystem
mkfs.vfat -n "boot" -S 512 "${LODEVMAPPER}p6"
mkfs.ext4 -L "linux-root" "${LODEVMAPPER}p7"
tune2fs -o journal_data_writeback "${LODEVMAPPER}p7"

# Mount filesystem
mkdir -p "$TEMP/rootfs"
mount "${LODEVMAPPER}p7" "$TEMP/rootfs"
mkdir -p "$TEMP/rootfs/boot/efi"
mount "${LODEVMAPPER}p6" "$TEMP/rootfs/boot/efi"

# Create image
rootfs/make_rootfs.sh "$TEMP/rootfs" "$DISTRO" "$VARIANT" "$BUILD_ARCH" "$MODEL" "$@"

# Write bootloader
dd if="$TEMP/rootfs/usr/lib/u-boot-${MODEL}/rksd_loader.img" of="${LODEVMAPPER}p1"

# Umount filesystem
fstrim "$TEMP/rootfs"
sync

# Move image into final location
mv "$TEMP_IMAGE" "$OUT_IMAGE"
