#!/bin/bash

set -eo pipefail

dev=$(findmnt / -n -o SOURCE)

if [[ $# -ne 1 ]]; then
	echo "usage: $0 <rootfs|flash-kernel>"
	exit 1
fi

case $dev in
	/dev/mmcblk*)
		DISK=${dev:0:12}
		;;

	/dev/sd*)
		DISK=${dev:0:8}
		;;

	*)
		echo "Unknown disk for $dev"
		exit 1
		;;
esac

case "$1" in
	rootfs)
		echo "Generating extlinux configuration on rootfs..."
		update_extlinux.sh

		echo "Switching boot to / on $DISK..."
		parted -s "$DISK" set 7 legacy_boot on
		parted -s "$DISK" set 6 legacy_boot off

		echo "Removing flash-kernel.."
		apt-get remove -y flash-kernel

		echo "Purging files..."
		rm -rf /boot/efi/{Image,Image.bak,initrd.img,initrd.img.bak,dtb,dtb.bak}
		;;

	flash-kernel)
		echo "Installing flash-kernel..."
		apt-get install -y flash-kernel

		echo "Generating flash-kernel..."
		flash-kernel

		echo "Switching boot to /boot/efi on $DISK..."
		parted -s "$DISK" set 6 legacy_boot on
		parted -s "$DISK" set 7 legacy_boot off
		;;

	*)
		echo "Invalid argument: $1"
		exit 1
		;;
esac

echo Done.
