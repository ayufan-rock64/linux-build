#!/bin/bash

set -e

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

print() {
	printf "%-15s: %s %s\n" "$1" "$2 $3" "$4"
}

cpu_frequency() {
	local cur=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
	local mhz=$(awk "BEGIN {printf \"%.2f\",$cur/1000}")
	print "CPU freq" $mhz "MHz"
}

scaling_govenor() {
	local gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  	print "Governor" $gov
}

cpu_count() {
	local cpus=$(grep -c processor /proc/cpuinfo)
	print "CPU count" $cpus
}

soc_temp() {
	local RAW_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
	local TEMP=$(awk "BEGIN {printf \"%.2f\",$RAW_TEMP/1000}")
	print "SoC Temp" $TEMP "C"
}

usage() {
	echo "Usage: $0 [-w] [-h]"
}

all() {
	cpu_frequency
	cpu_count
	scaling_govenor
	soc_temp
}


WATCH=""
for i in "$@"; do
	case $i in
	-w)
		WATCH=1
		shift
		;;
	-h|--help)
		usage
		exit 0
		;;
	*)
		usage
		exit 1
		;;
	esac
done

if [ -n "$WATCH" ]; then
	exec watch -n0.5 "$0"
else
	all
fi
