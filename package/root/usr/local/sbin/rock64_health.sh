#!/bin/bash

set -e

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

if grep -qi rockpro64 /proc/device-tree/compatible; then
	MODEL=rockpro64
fi

print() {
	printf "%-15s: %s %s\n" "$1" "$2 $3" "$4"
}

cpu_frequency() {
	if [ "$MODEL" == "rockpro64" ]; then
		local BigFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq) 2>/dev/null
		local LittleFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq) 2>/dev/null
                print "CPU freq b.L" $BigFreq $LittleFreq "MHz"
        else
		local CpuFreq=$(awk '{printf ("%.0f",$1/1000); }' < /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq) 2>/dev/null
		print "CPU freq" $CpuFreq "MHz"
	fi

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
	if [ "$MODEL" == rockpro64 ]; then
		local LittleTemp=$(awk '{printf ("%.2f",$1/1000) };' </sys/class/thermal/thermal_zone1/temp) 2>/dev/null
		local BigTemp=$(awk '{printf ("%.2f",$1/1000) };' </sys/class/thermal/thermal_zone0/temp) 2>/dev/null

		print "SoC Temp b.L" $BigTemp $LittleTemp "C"
	else
		local CpuTemp=$(awk '{printf ("%.2f",$1/1000) };' </sys/class/thermal/thermal_zone0/temp) 2>/dev/null
		print "SoC Temp" $CpuTemp "C"

	fi
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
