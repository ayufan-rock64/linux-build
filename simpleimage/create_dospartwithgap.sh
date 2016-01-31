#!/bin/sh
#
# Simple script to create a disk image with a DOS partition table and 20MB
# of free space before the fist partition.

set -e

disk="./dospartwithgap.img"

# sizes in sectors
offset=40960
bootsize=$((50 * 1024 * 2))

# size of complete image
dd if=/dev/zero of=$disk bs=1M count=100

fdisk ${disk} << EOF
n
p
1
${offset}
+${bootsize}
t
c
n
p
2
$(($offset + $bootsize + 1))

w
EOF
