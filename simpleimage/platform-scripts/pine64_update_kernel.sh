#!/bin/sh

set -e

URL="https://www.stdin.xyz/downloads/people/longsleep/pine64-images/linux/linux-pine64-latest.tar.xz"
PUBKEY="https://www.stdin.xyz/downloads/people/longsleep/longsleep.asc"
CURRENTFILE="/var/lib/misc/pine64_update_kernel.status"

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
trap cleanup EXIT

CURRENT=""
if [ -e "${CURRENTFILE}" ]; then
	CURRENT=$(cat $CURRENTFILE)
fi

echo "Checking for update ..."
ETAG=$(curl -I -H 'If-None-Match: "${CURRENT}' -s "${URL}"|grep ETag|awk -F'"' '{print $2}')

if [ "$ETAG" = "$CURRENT" ]; then
	echo "You are already on the latest version - no update required."
	exit 0
fi

FILENAME=$TEMP/$(basename ${URL})

downloadAndApply() {
	echo "Downloading Linux Kernel ..."
	curl "${URL}" --progress-bar --output "${FILENAME}"
	echo "Downloading signature ..."
	curl "${URL}.asc" --progress-bar --output "${FILENAME}.asc"
	echo "Downloading public key ..."
	curl "${PUBKEY}" --progress-bar --output "${TEMP}/pub.asc"

	echo "Verifying signature ..."
	gpg --homedir "${TEMP}" --yes -o "${TEMP}/pub.gpg" --dearmor "${TEMP}/pub.asc"
	gpg --homedir "${TEMP}" --status-fd 1 --no-default-keyring --keyring "${TEMP}/pub.gpg" --trust-model always --verify "${FILENAME}.asc" 2>/dev/null

	echo "Extracting ..."
	mkdir $TEMP/update
	tar -C $TEMP/update --numeric-owner -xJf "${FILENAME}"
	cp -RLp $TEMP/update/boot/* /boot/
	cp -RLp $TEMP/update/lib/* /lib/ 2>/dev/null || true
	cp -RLp $TEMP/update/usr/* /usr/

	echo "Fixing up ..."
	if [ ! -e "/boot/uEnv.txt" -a -e "/boot/uEnv.txt.in" ]; then
		# Install default uEnv.txt when not there.
		mv "/boot/uEnv.txt.in" "/boot/uEnv.txt"
	fi
}

if [ "$1" != "--mark-only" ]; then
	downloadAndApply
	echo "Done - you should reboot now."
fi
echo $ETAG > "$CURRENTFILE"
