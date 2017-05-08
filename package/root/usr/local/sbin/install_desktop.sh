#!/bin/bash

set -e

DESKTOP="$1"

if [ -z "$DESKTOP" ]; then
	echo "Usage: $0 <mate|i3>"
	exit 1
fi

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

# Default packages.
PACKAGES=(
	xserver-xorg-video-fbturbo
	libvdpau-sunxi1
	vdpauinfo
	aisleriot
	geany
	gnomine
	gnome-sudoku
	mplayer
	scratch
	smplayer
	smplayer-skins
	smplayer-themes
	smtube
)

# Add packages based on desktop selection.
case $DESKTOP in
	mate)
		PACKAGES+=(
			ubuntu-mate-core
			ubuntu-mate-desktop
			ubuntu-mate-lightdm-theme
			ubuntu-mate-wallpapers-xenial
			lightdm
		)
		;;

	i3|i3wm)
		PACKAGES+=(
			xserver-xorg-input-all
			xfonts-base
			slim
			rxvt-unicode-lite
			i3
			i3status
			i3lock
			suckless-tools
			network-manager
			pulseaudio
		)
		;;

	*)
		echo "Error: unsupported desktop environment $DESKTOP"
		exit 2
		;;
esac

# Install.
apt -y update
apt -y --no-install-recommends install ${PACKAGES[@]}

# Kill parport module loading, not available on arm64.
if [ -e "/etc/modules-load.d/cups-filters.conf" ]; then
	echo "" >/etc/modules-load.d/cups-filters.conf
fi

# Disable Pulseaudio timer scheduling which does not work with sndhdmi driver.
if [ -e "/etc/pulse/default.pa" ]; then
	sed -i 's/load-module module-udev-detect$/& tsched=0/g' /etc/pulse/default.pa
fi

# Desktop dependent post installation.
case $DESKTOP in
	i3|i3wm)
		if [ ! -d /usr/share/slim/themes/pine64 ]; then
			cp -ra /usr/share/slim/themes/default /usr/share/slim/themes/pine64
			wget -O /usr/share/slim/themes/pine64/background.png \
				https://github.com/longsleep/build-pine64-image/raw/master/bootlogo/bootlogo-pine64-1366x768.png
			sed -i "s/^current_theme(.*)/current_theme pine64/g" /etc/slim.conf
		fi
		;;

	*)
		;;
esac

echo
echo "Done - $DESKTOP installed - you should reboot now."
