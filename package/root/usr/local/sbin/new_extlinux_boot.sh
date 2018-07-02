#!/bin/bash

set -eo pipefail

dev=$(findmnt / -n -o SOURCE)

if [[ $# -ne 1 ]]; then
	echo "usage: $0 <enable|disable>"
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
	enable)
		echo "Enabling on $DISK..."
		parted -s "$DISK" set 7 legacy_boot on
		parted -s "$DISK" set 6 legacy_boot off
		;;

	disable)
		echo "Disabling on $DISK..."
		parted -s "$DISK" set 6 legacy_boot on
		parted -s "$DISK" set 7 legacy_boot off
		;;

	*)
		echo "Invalid argument: $1"
		exit 1
		;;
esac

echo Done.
