#!/bin/sh
#
# Simple script to replace boot0.bin in an existing image.
#

set -ex

out="$1"
boot0="$2"

if [ -z "$out" ]; then
	echo "Usage: $0 /dev/sdX [<boot0.bin>]"
	exit 1
fi

if [ -z "$boot0" ]; then
    boot0="../blobs/boot0.bin"
fi
boot0_position=8      # KiB
boot0_size=$(wc -c $boot0)

pv "$boot0" | dd conv=notrunc bs=1k seek=$boot0_position count=32 oflag=direct of="$out"

sync
