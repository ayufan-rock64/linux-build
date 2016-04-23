#!/bin/sh

set -e

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

pulseaudio_disable_tsched() {
	# Disable Pulseaudio timer scheduling which does not work with sndhdmi driver.
	if [ -e "/etc/pulse/default.pa" ]; then
		sed -i 's/load-module module-udev-detect$/& tsched=0/g' /etc/pulse/default.pa
	fi
}

echo "Applying various fixes ..."

pulseaudio_disable_tsched

echo "Done."
