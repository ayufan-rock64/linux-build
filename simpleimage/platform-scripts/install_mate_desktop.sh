#!/bin/sh

set -e

DISTRO=""

if hash apt-get 2>/dev/null; then
	DISTRO=debian
fi

if hash pacman 2>/dev/null; then
	DISTRO=arch
fi

if [[ -z "$DISTRO" ]]; then
	echo "This script requires a Debian based or Arch Linux distribution."
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

case $DISTRO in
	arch)
		pacman -Syu --noconfirm
		pacman -S --noconfirm --needed \
			xorg-server \
			xf86-video-fbturbo-git \
			mate \
			mate-extra \
			gtk-engine-murrine \
			pulseaudio \
			lightdm \
			lightdm-gtk-greeter
		sed -i 's|^#greeter-session=.*|greeter-session=lightdm-gtk-greeter|' /etc/lightdm/lightdm.conf
		systemctl enable lightdm
		;;
	debian)
		apt-get -y update
		apt-get -y --no-install-recommends install \
			xserver-xorg-video-fbturbo \
			ubuntu-mate-core \
			ubuntu-mate-desktop \
			ubuntu-mate-lightdm-theme \
			ubuntu-mate-wallpapers-xenial \
			lightdm \
			libvdpau-sunxi1 \
			vdpauinfo
		;;
	*)
		;;
esac

mkdir -p /etc/X11/xorg.conf.d

# Make X11 use fbturbo driver.
cat > "/etc/X11/xorg.conf.d/40-pine64-fbturbo.conf" <<EOF
Section "Device"
		Identifier      "Allwinner A10/A13 FBDEV"
		Driver          "fbturbo"
		Option          "fbdev" "/dev/fb0"

		Option          "SwapbuffersWait" "true"
EndSection
EOF

# Add configuration for Pinebook touchpad so it is usable.
cat > "/etc/X11/xorg.conf.d/50-pine64-pinebook-touchpad.conf" <<EOF
Section "InputClass"
	Identifier "HAILUCK CO.,LTD USB KEYBOARD"
	MatchIsPointer "1"
	MatchDevicePath "/dev/input/event*"

	Option "AccelerationProfile" "2"
	Option "AdaptiveDeceleration" "1"
	Option "ConstantDeceleration" "2.4" # Pinebook 14"
	#Option "ConstantDeceleration" "1.2" # Pinebook 11"
EndSection
EOF

# Kill parport module loading, not available on arm64.
if [ -e "/etc/modules-load.d/cups-filters.conf" ]; then
	echo "" >/etc/modules-load.d/cups-filters.conf
fi

# Disable Pulseaudio timer scheduling which does not work with sndhdmi driver.
if [ -e "/etc/pulse/default.pa" ]; then
	sed -i 's/load-module module-udev-detect$/& tsched=0/g' /etc/pulse/default.pa
fi

# Enable VDPAU_SUNXI globally.
if [ -d "/etc/X11/Xsession.d" -a ! -e "/etc/X11/Xsession.d/30pine64-vdpau-sunxi" ]; then
	cat > "/etc/X11/Xsession.d/30pine64-vdpau-sunxi" <<EOF
export VDPAU_DRIVER=sunxi
EOF
fi

echo "Done - you should reboot now."
