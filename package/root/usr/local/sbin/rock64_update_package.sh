#!/bin/sh

set -e

VERSION="$1"

if [ -z "$1" ]; then
	VERSION=$(curl -s https://api.github.com/repos/ayufan-rock64/linux-build/releases/latest | jq -r ".tag_name")
	if [ -z "$VERSION" ]; then
		echo "Latest release was not found. Please go to: $LATEST_LIST"
		exit 1
	fi

	echo "Using latest release: $VERSION."
fi

DEVICE="/dev/mmcblk0"
URL="https://github.com/ayufan-rock64/linux-build/releases/download/$VERSION/linux-rock64-package-$VERSION.deb"

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

echo "Checking for update ..."
FILENAME=$TEMP/$(basename ${URL})

if [ -z "$MARK_ONLY" ]; then
	echo "Downloading model package ..."
	curl -L "${URL}" -f --progress-bar --output "${FILENAME}"

    echo "Installing model package ..."
    sudo dpkg -i "${FILENAME}"

	echo "Done - you should reboot now."
else
	echo "Mark only."
fi
