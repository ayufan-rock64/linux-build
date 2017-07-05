#!/bin/bash

set -xe

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

gdisk /dev/mmcblk0 <<EOF
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

partprobe /dev/mmcblk0

resize2fs /dev/mmcblk0p7
