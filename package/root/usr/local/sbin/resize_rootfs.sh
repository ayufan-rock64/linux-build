#!/bin/bash

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

case $(findmnt / -n -o SOURCE) in
	/dev/mmcblk0p7)
		DISK=/dev/mmcblk0
		NAME=emmc
		;;

	/dev/mmcblk1p7)
		DISK=/dev/mmcblk1
		NAME=sd
		;;

	*)
		echo "Unknown disk for /"
		exit 1
		;;
esac

echo "Resizing $DISK ($NAME)..."

set -xe

gdisk "$DISK" <<EOF
x
e
m
d
7
n
7


8300
c
7
root
w
Y
EOF

partprobe "$DISK"

resize2fs "$DISK"
