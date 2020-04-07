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

PWD=$(readlink -f .)
TEMP=$(mktemp -p $PWD -d -t "$MODEL-build-XXXXXXXXXX")
echo "> Building in $TEMP ..."

cleanup() {
    echo "> Cleaning up ..."
    umount "$TEMP/rootfs/boot/efi" || true
    umount "$TEMP/rootfs/boot" || true
    umount "$TEMP/rootfs" || true
    kpartx -d "${LODEV}" || true
    losetup -d "${LODEV}" || true
    rm -rf "$TEMP"
}
trap cleanup EXIT

TEMP_IMAGE="${OUT_IMAGE}.tmp"

set -ex

# Define max sizes and offsets
EFI_OFFSET=$((4*1024*1024/512))    # 4MiB
BOOT_OFFSET=$((16*1024*1024/512))  # 16MiB
ROOT_OFFSET=$((256*1024*1024/512)) # 256MiB

MIN_SIZE=$((500*1000*1000/512))    # 500MB
SIZE_STEP=$((250*1000*1000/512))   # 250MB
MAX_SIZE=$((8*1000*1000*1000/512)) # 8GB

# Create
rm -f "$TEMP_IMAGE"
truncate -s "$((MAX_SIZE*512))" "$TEMP_IMAGE"

# Create partitions
echo Updating GPT...
parted -s "${TEMP_IMAGE}" mklabel gpt
parted -s "${TEMP_IMAGE}" unit s mkpart loader1             64                  $((EFI_OFFSET-1))   # ~4MB
parted -s "${TEMP_IMAGE}" unit s mkpart boot_efi    fat16   $((EFI_OFFSET))     $((BOOT_OFFSET-1))  # up-to 16MB => ~12MB
parted -s "${TEMP_IMAGE}" unit s mkpart linux_boot  ext4    $((BOOT_OFFSET))    $((ROOT_OFFSET-1)) # up-to 132MB => 116MB
parted -s "${TEMP_IMAGE}" unit s mkpart linux_root  ext4    $((ROOT_OFFSET))   100%                 # rest
parted -s "${TEMP_IMAGE}" set 3 legacy_boot on

# Assign lodevice
LODEV=$(losetup -f --show "${TEMP_IMAGE}")

# Map path from /dev/loop to /dev/mapper/loop
LODEVMAPPER="${LODEV/\/dev\/loop/\/dev\/mapper\/loop}"

# Assign partitions
kpartx -a "$LODEV"

LODEV_UBOOT="${LODEVMAPPER}p1"
LODEV_EFI="${LODEVMAPPER}p2"
LODEV_BOOT="${LODEVMAPPER}p3"
LODEV_ROOT="${LODEVMAPPER}p4"

# Make filesystem
mkfs.vfat -n "boot-efi" -S 512 "${LODEV_EFI}"
mkfs.ext4 -L "linux-boot" "${LODEV_BOOT}"
mkfs.ext4 -L "linux-root" "${LODEV_ROOT}"
tune2fs -o journal_data_writeback "${LODEV_ROOT}"

# Mount filesystem
mkdir -p "$TEMP/rootfs"
mount -o data=writeback,commit=3600 "${LODEV_ROOT}" "$TEMP/rootfs"
mkdir -p "$TEMP/rootfs/boot"
mount "${LODEV_BOOT}" "$TEMP/rootfs/boot"
mkdir -p "$TEMP/rootfs/boot/efi"
mount "${LODEV_EFI}" "$TEMP/rootfs/boot/efi"

# Create image
unshare -m -u -i -p --mount-proc --fork -- \
    rootfs/make-rootfs.sh "$TEMP/rootfs" "$DISTRO" "$VARIANT" "$BUILD_ARCH" "$MODEL" "$@"

# Write bootloader
dd if="$TEMP/rootfs/usr/lib/u-boot-${MODEL}/rksd_loader.img" of="${LODEV_UBOOT}"

# Sync all filesystems
sync -f "$TEMP/rootfs" "$TEMP/rootfs/boot" "$TEMP/rootfs/boot/efi"
fstrim "$TEMP/rootfs"
fstrim "$TEMP/rootfs/boot"
df -h "$TEMP/rootfs" "$TEMP/rootfs/boot" "$TEMP/rootfs/boot/efi"
mv "$TEMP/rootfs/all-packages.txt" "$(dirname "$OUT_IMAGE")/$(basename "$OUT_IMAGE" .img)-packages.txt"

# Umount filesystems
umount "$TEMP/rootfs/boot/efi"
umount "$TEMP/rootfs/boot"
umount "$TEMP/rootfs"

# Do fsck
fsck.ext4 -f -y "$LODEV_ROOT"

for IMAGE_SIZE in $(seq $MIN_SIZE $SIZE_STEP $MAX_SIZE) $MAX_SIZE
do
    # We need 33 sectors for GPT, give it 128
    ROOT_SIZE=$((IMAGE_SIZE-ROOT_OFFSET-128))

    # try to resize rootfs to fit into `IMAGE_SIZE`
    if resize2fs "$LODEV_ROOT" "${ROOT_SIZE}"; then
        # resize partition 7 to as much as possible
        echo ",$((ROOT_SIZE)),,," | sfdisk "${LODEV}" -N4 --force
        break
    fi
done

# Cleanup
cleanup
trap - EXIT

# Now truncate the image, and fix it
truncate -s "$((IMAGE_SIZE*512))" "$TEMP_IMAGE"
sgdisk -e "$TEMP_IMAGE"
parted -s "${TEMP_IMAGE}" print

# Move image into final location
mv "$TEMP_IMAGE" "$OUT_IMAGE"
