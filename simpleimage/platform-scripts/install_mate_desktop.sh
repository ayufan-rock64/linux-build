#!/bin/sh

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

# Mail blobs can be downloaded from the following URL. Does not help much
# for now, as fbturbo requires mali-drm module to enable this in X11. Might
# be of some use for framebuffer.
#wget http://malideveloper.arm.com/downloads/drivers/binary/utgard/r5p0-01rel0/mali-450_r5p0-01rel0_linux_1+fbdev+arm64-v8a.tar.gz
