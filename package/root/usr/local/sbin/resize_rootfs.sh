#!/bin/bash

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

dev=$(findmnt / -n -o SOURCE)

case $dev in
	/dev/mmcblk*)
		DISK=${dev:0:12}
		NAME="sd/emmc"
		;;

	/dev/sd*)
		DISK=${dev:0:8}
		NAME="hdd/ssd"
		;;

	*)
		echo "Unknown disk for $dev"
		exit 1
		;;
esac

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

resize2fs "$dev"
