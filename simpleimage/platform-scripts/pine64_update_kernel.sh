#!/bin/sh

set -e

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

VERSION="latest"
if [ -n "$1" ]; then
	VERSION="$1"
fi

VARIANTFILE="/var/lib/misc/pine64_update_kernel.variant"
VARIANT=""
if [ -e "$VARIANTFILE" ]; then
	VARIANT=$(cat $VARIANTFILE)
fi

if [ -n "$2" ]; then
	VARIANT="$2"
	if [ "$VARIANT" = "default" ]; then
		VARIANT=""
	fi
fi

if [ -n "$VARIANT" ]; then
	echo "Using Kernel variant: $VARIANT"
fi

URL="https://www.stdin.xyz/downloads/people/longsleep/pine64-images/linux/linux-pine64$VARIANT-$VERSION.tar.xz"
PUBKEY="https://www.stdin.xyz/downloads/people/longsleep/longsleep.asc"
CURRENTFILE="/var/lib/misc/pine64_update_kernel.status"

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
	echo "Version $VERSION$VARIANT not found."
	exit 1
fi

ETAG="$ETAG$VARIANT"
if [ "$ETAG" = "$CURRENT" ]; then
	echo "You are already on $VERSION version - abort."
	exit 0
fi

FILENAME=$TEMP/$(basename ${URL})

downloadAndApply() {
	echo "Downloading Linux Kernel ..."
	curl "${URL}" -f --progress-bar --output "${FILENAME}"
	echo "Downloading signature ..."
	curl "${URL}.asc" -f --progress-bar --output "${FILENAME}.asc"
	echo "Downloading public key ..."
	curl "${PUBKEY}" -f --progress-bar --output "${TEMP}/pub.asc"

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

	VERSION=""
	if [ -e "$TEMP/update/boot/Image.version" ]; then
		VERSION=$(cat $TEMP/update/boot/Image.version)
	fi

	if [ -n "$VERSION" ]; then
		# Create symlink to headers if not there.
		if [ ! -e /lib/modules/$VERSION/build ]; then
			ln -s /usr/src/linux-headers-$VERSION /lib/modules/$VERSION/build
		fi

		# New Kernel with postinst support ...
		depmod "$VERSION"

		echo "Running postinst for $VERSION ..."
		if [ -e "/etc/kernel/header_postinst.d" ]; then
			run-parts -v -a "$VERSION" /etc/kernel/header_postinst.d
		fi
	fi

}

if [ -z "$MARK_ONLY" ]; then
	downloadAndApply
	sync
	echo "Done - you should reboot now."
else
	echo "Mark only."
fi
echo "$ETAG" > "$CURRENTFILE"
echo "$VARIANT" > "$VARIANTFILE"
sync
