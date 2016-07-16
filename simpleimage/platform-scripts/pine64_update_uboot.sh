#!/bin/sh

set -e

VERSION="latest"
if [ -n "$1" ]; then
	VERSION="$1"
fi

DEVICE="/dev/mmcblk0"
URL="https://www.stdin.xyz/downloads/people/longsleep/pine64-images/simpleimage-pine64-$VERSION.img.xz"
PUBKEY="https://www.stdin.xyz/downloads/people/longsleep/longsleep.asc"
CURRENTFILE="/var/lib/misc/pine64_update_uboot.status"

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

TEMP=$(mktemp -d -p /var/tmp)

cleanup() {
	if [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}
trap cleanup EXIT INT

CURRENT=""
if [ -e "${CURRENTFILE}" ]; then
	CURRENT=$(cat $CURRENTFILE)
fi

echo "Checking for update ..."
ETAG=$(curl -f -I -H "If-None-Match: \"${CURRENT}\"" -s "${URL}"|grep ETag|awk -F'"' '{print $2}')

if [ -z "$ETAG" ]; then
	echo "Version $VERSION not found."
	exit 1
fi

if [ "$ETAG" = "$CURRENT" ]; then
	echo "You are already on $VERSION version - abort."
	exit 0
fi

FILENAME=$TEMP/$(basename ${URL})

downloadAndApply() {
	echo "Downloading U-Boot image ..."
	curl "${URL}" -f --progress-bar --output "${FILENAME}"
	echo "Downloading signature ..."
	curl "${URL}.asc" -f --progress-bar --output "${FILENAME}.asc"
	echo "Downloading public key ..."
	curl "${PUBKEY}" -f --progress-bar --output "${TEMP}/pub.asc"

	echo "Verifying signature ..."
	gpg --homedir "${TEMP}" --yes -o "${TEMP}/pub.gpg" --dearmor "${TEMP}/pub.asc"
	gpg --homedir "${TEMP}" --status-fd 1 --no-default-keyring --keyring "${TEMP}/pub.gpg" --trust-model always --verify "${FILENAME}.asc" 2>/dev/null

	local boot0_position=8     # KiB
	local boot0_size=64        # KiB
	local uboot_position=19096 # KiB
	local uboot_size=1384      # KiB
	echo "Processing ..."
	xz -d -c "${FILENAME}" >"${TEMP}/simpleimage.img"
	dd if="${TEMP}/simpleimage.img" status=none bs=1k skip=$boot0_position count=$boot0_size of="${TEMP}/boot0.img"
	dd if="${TEMP}/simpleimage.img" status=none bs=1k skip=$uboot_position count=$uboot_size of="${TEMP}/uboot.img"
	echo "Flashing boot0 ..."
	dd if="${TEMP}/boot0.img" conv=notrunc bs=1k seek=$boot0_position oflag=sync of="${DEVICE}"
	echo "Flashing U-Boot ..."
	dd if="${TEMP}/uboot.img" conv=notrunc bs=1k seek=$uboot_position oflag=sync of="${DEVICE}"
}

if [ -z "$MARK_ONLY" ]; then
	if [ ! -b "$DEVICE" ]; then
		echo "Block device ${DEVICE} not found."
		exit 2
	fi
	downloadAndApply
	sync
	echo "Done - you should reboot now."
else
	echo "Mark only."
fi
echo $ETAG > "$CURRENTFILE"
