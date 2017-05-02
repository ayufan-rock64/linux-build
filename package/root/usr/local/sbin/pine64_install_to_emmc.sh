#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

echo "Pine A64/Pinebook release installer!"
echo "(C) 2017. Kamil Trzciński (https://ayufan.eu)."
echo ""

usage() {
    echo "Usage:"
    echo "$ $0 <system> [version]"
    echo ""
    echo "Systems:"
    echo " - xenial-minimal (https://github.com/ayufan-pine64/linux-build/releases)"
    echo " - xenial-mate (https://github.com/ayufan-pine64/linux-build/releases)"
    echo " - xenial-i3 (https://github.com/ayufan-pine64/linux-build/releases)"
    echo " - android-7.0 (https://github.com/ayufan-pine64/android-7.0/releases)"
    echo " - android-7.1 (https://github.com/ayufan-pine64/android-7.1/releases)"
    echo ""
    echo "Version:"
    echo " - latest will be used if version is not defined"
    exit 1
}

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
    usage
fi

if [[ ! -d /sys/devices/soc.0/1c10000.sdmmc/mmc_host/mmc1 ]]; then
    echo "You should boot from SD card"
    exit 1
fi

if [[ ! -e /dev/mmcblk1 ]]; then
    echo "You should boot from SD card"
    exit 1
fi

case "$1" in
    xenial-minimal|xenial-mate|xenial-i3)
        REPO="ayufan-pine64/linux-build"
        PREFIX="$1-$(cat /etc/pine64_model)-bspkernel-"
        SUFFIX="-[0-9]*.img.xz"
        ARCHIVER="xz -d"
        ;;

    android-7.0|android-7.1)
        REPO="ayufan-pine64/$1"
        if [[ "$(cat /etc/pine64_model)" -eq "pinebook" ]]; then
            PREFIX="$1-pine-a64-pinebook-v"
        else
            PREFIX="$1-pine-a64-v"
        fi
        SUFFIX="-r[0-9]*.img.gz"
        ARCHIVER="gzip -d"
        ;;

    *)
        echo "Unknown system: $1"
        echo ""
        usage
        ;;
esac

VERSION="$2"

if [[ -z "$VERSION" ]]; then
	VERSION=$(curl -f -sS https://api.github.com/repos/$REPO/releases/latest | jq -r ".tag_name")
	if [ -z "$VERSION" ]; then
		echo "Latest release was not for $1."
        echo "Please go to: https://github.com/$REPO/releases/latest"
        exit 1
	fi

	echo "Using latest release: $VERSION from https://github.com/$REPO/releases."
fi

NAME="$PREFIX$VERSION$SUFFIX"
NAME_SAFE="${NAME//./\\.}"
VERSION_SAFE="${VERSION//./\\.}"

echo "Looking for download URL..."
DOWNLOAD_URL=$(curl -f -sS https://api.github.com/repos/$REPO/releases | \
    jq -r ".[].assets | .[].browser_download_url" | \
    ( grep -o "https://github\.com/$REPO/releases/download/$VERSION_SAFE/$NAME_SAFE" || true))

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "The download URL for $NAME not found".
    echo "Look at https://github.com/$REPO/releases for correct versions."
    exit 1
fi

echo "Doing this will overwrite all data stored on eMMC."

while true; do
    echo "Type YES to continue or Ctrl-C to abort."
    read CONFIRM
    if [[ "$CONFIRM" == "YES" ]]; then
        break
    fi
done

echo ""
echo "Using $DOWNLOAD_URL..."
echo "Umounting..."
umount -f /dev/mmcblk1* || true
echo ""

echo "Downloading and writing to /dev/mmcblk1..."
curl -L -f "$DOWNLOAD_URL" | $ARCHIVER | dd bs=30M of=/dev/mmcblk1
sync
echo ""

echo "Done."
