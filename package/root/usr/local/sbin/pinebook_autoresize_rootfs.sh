#!/bin/sh -e
#
# rc.local
#
#This script is executed to resize the rootfs and it is execured only once after boot up
#

if [ -e /etc/original_rc.local ]; then
	/usr/local/sbin/resize_rootfs.sh
	mv /etc/original_rc.local /etc/rc.local
fi

rm -f "$0"

exit 0
