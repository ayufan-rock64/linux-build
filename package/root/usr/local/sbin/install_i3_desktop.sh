#!/bin/sh

set -e

DISTRO=""

if hash apt-get 2>/dev/null; then
	DISTRO=debian
fi

if [ -z "$DISTRO" ]; then
	echo "This script requires a Debian based Linux distribution."
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

case $DISTRO in
	debian)
		apt-get -y update
		apt-get -y --no-install-recommends install \
			xserver-xorg-video-fbturbo \
			xserver-xorg-input-all \
			xfonts-base \
			slim \
			rxvt-unicode-lite \
			i3 \
			i3status \
			i3lock \
			suckless-tools \
			network-manager
		;;
	*)
		;;
esac

if [ ! -d /usr/share/slim/themes/pine64 ]; then
	cp -ra /usr/share/slim/themes/default /usr/share/slim/themes/pine64
	wget -O /usr/share/slim/themes/pine64/background.png \
		https://github.com/longsleep/build-pine64-image/raw/master/bootlogo/bootlogo-pine64-1366x768.png
	sed "s/^current_theme(.*)/current_theme pine64/g" /etc/slim.conf
fi

echo "Done - you should reboot now."
