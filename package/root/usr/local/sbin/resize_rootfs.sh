#!/bin/bash

if [ $# -ne 1 ]; then
	echo "No arguments provided... please specify device to resize!"
	echo "e.g. $(basename $0) /dev/mmcblk1"
	exit 1
fi

if [ ! -b "$1" ]; then
	echo "Specified device '$1' does not exist! Abort!"
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

set -xe

gdisk "$1" <<EOF
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

partprobe "$1"

resize2fs "${1}p7"
