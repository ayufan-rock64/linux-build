#!/bin/sh

set -e

DEST="$1"

if [ -z "$DEST" ]; then
	echo "Usage: $0 <destination-path> [linux-folder] [extra-version]"
	exit 1
fi

LINUX="../linux"
BOOT_TOOLS="../boot-tools"

if [ -n "$2" ]; then
	LINUX="$2"
fi

EXTRAVERSION="$3"

echo "Using Linux from $LINUX ..."

TEMP=$(mktemp -d)
mkdir $TEMP/boot

cleanup() {
	if [ -d "$TEMP" ]; then
		rm -rf "$TEMP"
	fi
}
trap cleanup EXIT

./install_kernel.sh "$TEMP/boot" "$LINUX"
./install_kernel_modules.sh "$TEMP" "$LINUX"
./install_kernel_headers.sh "$TEMP" "$LINUX"

echo "Copying boot of boot-tools tools..."
pwd
cp -rv "$BOOT_TOOLS/boot/" "$TEMP/"

# Use uEnv.txt.in so we do not overwrite customizations on next update.
mv "$TEMP/boot/uEnv.txt" "$TEMP/boot/uEnv.txt.in"

echo "Building $DEST ..."
tar -C "$TEMP" -cJ --owner=0 --group=0 --xform='s,./,,' -f "$DEST" .

echo "Done - $DEST"
