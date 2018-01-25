#!/bin/bash

if [[ "$(id -u)" -ne "0" ]]; then
	echo "This script requires root."
	exit 1
fi

dev=$(findmnt / -n -o SOURCE)

if [[ "${dev:0:11}" == "/dev/mmcblk" ]]
then
	DISK=${dev:0:12}
	NAME="sd/emmc"
elif [[ "${dev:0:7}" == "/dev/sd" ]]
then
	DISK=${dev:0:8}
	NAME="hdd/ssd"
else
	echo "Unknown disk for $dev"
	exit 1
fi

echo "Resizing $DISK ($NAME -- $dev)..."

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
