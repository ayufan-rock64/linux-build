#!/bin/bash

set -e

DESKTOP="$1"

if [ -z "$DESKTOP" ]; then
	echo "Usage: $0 <mate|i3|gnome|xfce4|lxde>"
	exit 1
fi

DISTRO=""
if hash apt-get 2>/dev/null; then
	DISTRO=$(lsb_release -i -s)
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
	aisleriot
	geany
	gnome-mines
	gnome-sudoku
	mplayer
	scratch
	smplayer
	smplayer-themes
	smtube
	xserver-xorg
	mesa-utils-extra
)

# Video/3d acceleration packages
PACKAGES+=(
	xserver-xorg-video-armsoc
	libdrm-rockchip1
	libmali-rk-utgard-450-r7p0
	ffmpeg
	mpv
)

# Additional packages
PACKAGES+=(
	xserver-xorg-input-all
	xfonts-base
	rxvt-unicode-lite
	suckless-tools
	network-manager
	pulseaudio
)

case $DISTRO in
	Ubuntu)
		PACKAGES+=(
			chromium-browser
			firefox
			gstreamer1.0-rockchip1
		)
		;;

	Debian)
		PACKAGES+=(
			chromium
			chromium-widevine
		)
		;;

	*)
		echo "Error: unsupported desktop environment $DESKTOP-$DISTRO"
		exit 2
		;;
esac

# Add packages based on desktop selection.
case $DESKTOP-$DISTRO in
	mate-Ubuntu)
		PACKAGES+=(
			ubuntu-mate-desktop
			ubuntu-mate-lightdm-theme
			ubuntu-mate-wallpapers-xenial
			lightdm
		)
		;;

	mate-Debian)
		PACKAGES+=(
			mate-desktop-environment
			mate-desktop-environment-extras
			desktop-base
			lightdm
		)
		;;

	gnome-Ubuntu)
		PACKAGES+=(
			ubuntu-gnome-desktop
			ubuntu-gnome-wallpapers-xenial
		)
		;;

	gnome-Debian)
		PACKAGES+=(
			gnome
			desktop-base
		)
		;;

	i3-Ubuntu|i3-Debian)
		PACKAGES+=(
			i3
			i3status
			i3lock
			slim
		)
		;;

	xfce4-Ubuntu|xfce4-Debian)
		PACKAGES+=(
			xfce4
			xfce4-goodies
			slim
		)
		;;

	lxde-Ubuntu|lxde-Debian)
		PACKAGES+=(
			lxde
			lxdm
		)
		;;

	*)
		echo "Error: unsupported desktop environment $DESKTOP"
		exit 2
		;;
esac

# Install.
apt -y update
apt -y install ${PACKAGES[@]}

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
	mate)
		# Change default wallpaper
		dpkg-divert --divert /usr/share/backgrounds/ubuntu-mate-common/Ubuntu-Mate-Cold-stock.jpg --rename /usr/share/backgrounds/ubuntu-mate-common/Ubuntu-Mate-Cold.jpg || true
		ln -s /usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-6.jpg /usr/share/backgrounds/ubuntu-mate-common/Ubuntu-Mate-Cold.jpg
		;;

	i3|i3wm)
		if [ ! -d /usr/share/slim/themes/rock64 ]; then
			cp -ra /usr/share/slim/themes/default /usr/share/slim/themes/rock64
			ln -s /usr/share/backgrounds/ubuntu-mate-rock64/ROCK64-Wallpaper-6.jpg /usr/share/slim/themes/rock64/background.png
			sed -i "s/^current_theme(.*)/current_theme rock64/g" /etc/slim.conf
		fi
		;;

	*)
		;;
esac

echo
echo "Done - $DESKTOP installed - you should reboot now."
