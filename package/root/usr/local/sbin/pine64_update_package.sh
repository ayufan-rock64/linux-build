#!/bin/sh

set -e

VERSION="$1"

if [ -z "$1" ]; then
	VERSION=$(curl -s https://api.github.com/repos/ayufan-pine64/linux-build/releases/latest | jq -r ".tag_name")
	if [ -z "$VERSION" ]; then
		echo "Latest release was not found. Please go to: $LATEST_LIST"
		exit 1
	fi

	echo "Using latest release: $VERSION."
fi

DEVICE="/dev/mmcblk0"
URL="https://github.com/ayufan-pine64/linux-build/releases/download/$VERSION/linux-pine64-package-$(cat /etc/pine64_model)-$VERSION.deb"
CURRENTFILE="/var/lib/misc/pine64_update_package.status"

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
ETAG=$(curl -L -f -I -H "If-None-Match: \"${CURRENT}\"" -s "${URL}"|grep ETag|awk -F'"' '{print $2}')

if [ -z "$ETAG" ]; then
	echo "Version $VERSION not found."
	exit 1
fi

if [ "$ETAG" = "$CURRENT" ]; then
	echo "You are already on $VERSION version - abort."
	exit 0
fi

FILENAME=$TEMP/$(basename ${URL})

if [ -z "$MARK_ONLY" ]; then
	echo "Downloading model package ..."
	curl -L "${URL}" -f --progress-bar --output "${FILENAME}"

    echo "Installing model package ..."
    dpkg -i "${FILENAME}"

	echo "Done - you should reboot now."
else
	echo "Mark only."
fi

echo $ETAG > "$CURRENTFILE"
