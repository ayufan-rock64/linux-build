#!/bin/sh

# Original code from https://github.com/ayufan-pine64/linux-build/blob/120285aa84c6b12db8eae043b4a17b746f29e7a8/package/root/usr/local/sbin/pinebook_restore_sound.sh - thanks!

set -e

if [ -x /usr/bin/amixer -a -e /sys/module/sunxi_sndcodec/initstate ]; then
	/usr/bin/amixer -q -c 'audiocodec' set 'DACL Mixer AIF1DA0L' on
	/usr/bin/amixer -q -c 'audiocodec' set 'DACR Mixer AIF1DA0R' on

	echo "Sunxi audiocodec DACL/DACR enabled"
fi
