#!/bin/sh

set -x

mkdir -p /var/lib/pine64

if [ ! -e /var/lib/pine64/resized ]; then
   touch /var/lib/pine64/resized
   /usr/local/sbin/resize_rootfs.sh
fi
