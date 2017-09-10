#!/bin/sh

set -x

mkdir -p /var/lib/rock64

if [ ! -e /var/lib/rock64/resized ]; then
   touch /var/lib/rock64/resized
   /usr/local/sbin/resize_rootfs.sh
fi
