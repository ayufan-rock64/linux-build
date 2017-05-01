#!/bin/sh

set -e

DISTRO=""

if hash apt-get 2>/dev/null; then
	DISTRO=debian
fi

if [[ -z "$DISTRO" ]]; then
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
			slim \
			xvt \
			openbox
		;;
	*)
		;;
esac

if [ ! -d /usr/share/slim/themes/pine64 ]; then
	cp -ra /usr/share/slim/themes/default /usr/share/slim/themes/pine64
	wget -O /usr/share/slim/themes/pine64/background.png \
		https://github.com/longsleep/build-pine64-image/raw/master/bootlogo/bootlogo-pine64-1366x768.png
	sed s/^current_theme(.*)/current_theme pine64/g /etc/slim.conf
fi

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

echo "Done - you should reboot now."
