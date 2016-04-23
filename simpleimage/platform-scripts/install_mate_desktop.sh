#!/bin/sh

set -e

if ! hash apt-get 2>/dev/null; then
	echo "This script requires a Debian based distribution."
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

apt-get -y update
apt-get -y --no-install-recommends install \
	xserver-xorg-video-fbturbo \
	ubuntu-mate-core \
	ubuntu-mate-desktop \
	ubuntu-mate-lightdm-theme \
	ubuntu-mate-wallpapers-xenial \
	lightdm

cat > "/etc/X11/xorg.conf" <<EOF
Section "Device"
        Identifier      "Allwinner A10/A13 FBDEV"
        Driver          "fbturbo"
        Option          "fbdev" "/dev/fb0"

        Option          "SwapbuffersWait" "true"
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

# Mail blobs can be downloaded from the following URL. Does not help much
# for now, as fbturbo requires mali-drm module to enable this in X11. Might
# be of some use for framebuffer.
#wget http://malideveloper.arm.com/downloads/drivers/binary/utgard/r5p0-01rel0/mali-450_r5p0-01rel0_linux_1+fbdev+arm64-v8a.tar.gz
