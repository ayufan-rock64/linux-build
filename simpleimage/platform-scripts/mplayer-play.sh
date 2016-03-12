#!/bin/sh

set -e

if [ ! -w /dev/ion ]; then
	echo "Error: /dev/ion missing or no access"
	exit 1
fi

if [ ! -w /dev/cedar_dev ]; then
	echo "Error: /dev/cedar_dev missing or no access"
	exit 1
fi

export VDPAU_DRIVER=sunxi
exec mplayer -vo vdpau -vc ffmpeg12vdpau,ffh264vdpau,ffhevcvdpau, $@
