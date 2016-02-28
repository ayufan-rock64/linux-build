#!/bin/sh

set -e
set -x

DEVICE="/dev/mmcblk0"
PART="2"

resize() {
	start=$(fdisk -l ${DEVICE}|grep ${DEVICE}p${PART}|awk '{print $2}')
	echo $start

	set +e
	fdisk ${DEVICE} <<EOF
p
d
2
n
p
2
$start

w
EOF
	set -e

	partx -u ${DEVICE}
	resize2fs ${DEVICE}p${PART}
}

resize

echo "Done!"