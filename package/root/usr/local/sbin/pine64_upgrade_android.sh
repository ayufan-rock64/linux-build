#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

echo "Pine A64/Pinebook Android upgrader (experimental)!"
echo "(C) 2017. Kamil Trzciński (https://ayufan.eu)."
echo ""

usage() {
    echo "Usage:"
    echo "$ $0 <device> <system> [version]"
    echo ""
    echo "Systems:"
    echo " - android-7.0 (https://github.com/ayufan-pine64/android-7.0/releases)"
    echo " - android-7.1 (https://github.com/ayufan-pine64/android-7.0/releases)"
    echo ""
    echo "Version:"
    echo " - latest will be used if version is not defined"
    exit 1
}

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
    usage
fi

if [[ "$2" != "android-7.0" ]] || [[ "$2" != "android-7.1" ]]; then
    usage
fi

REPO="ayufan-pine64/$2"
if [[ "$(cat /etc/pine64_model)" -eq "pinebook" ]]; then
    PREFIX="$2-pine-a64-pinebook-v"
else
    PREFIX="$2-pine-a64-v"
fi
SUFFIX="-r[0-9]*.img.gz"
ARCHIVER="gzip -d"

VERSION="$3"

if [[ -z "$VERSION" ]]; then
	VERSION=$(curl -f -sS https://api.github.com/repos/$REPO/releases/latest | jq -r ".tag_name")
	if [ -z "$VERSION" ]; then
		echo "Latest release was not for $2."
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
umount -f $1* || true
echo ""

START=16 # 8k
END=4337664 # 2,220,883,968

echo "Downloading and upgrade $1..."
curl -L -f "$DOWNLOAD_URL" | $ARCHIVER | \
    tail -c "+$((START*512))" | \
    dd bs=8k seek="$((START/16))" count="$(((END-START)/16))" "of=$1"
sync
echo ""

echo "Done."
