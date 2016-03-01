#!/bin/sh
#
# Simple script to print some health data for Pine64. Some details were
# shamelessly stolen from http://pastebin.com/bSTYCQ5u. Thanks tkaiser.
#
# Run this script like `sudo watch -n.5 pine64_health.sh`.
#

set -e

print() {
	printf "%-15s: %s %s\n" "$1" "$2 $3" "$4"
}

cpu_frequency() {
	local cur=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
	local ghz=$(awk "BEGIN {printf \"%.2f\",$cur/1000}")
	print "CPU freq" $ghz "GHz"
}

scaling_govenor() {
	local gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
	print "Governor" $gov
}

cpu_count() {
	local cpu=$(/usr/bin/awk -F": " '/^processor/ {print $2}' < /proc/cpuinfo | /usr/bin/tail -n1)
	local cpus=$((1+cpu))
	print "CPU count" $cpus
}

vcore_voltage() {
	local uv=$(cat /sys/devices/platform/axp81x_board/axp-regulator.41/regulator/regulator.2/microvolts)
	local v=$(awk "BEGIN {printf \"%.2f\",$uv/1000000}")
	print "Core voltage" $v "V"
}

soc_temp() {
	local temp=$(cat /sys/devices/virtual/thermal/thermal_zone0/temp)
	print "SOC Temp" $temp "C"
}

cooling_state() {
	local state=$(cat /sys/devices/virtual/thermal/cooling_device0/cur_state)
	print "Cooling state" $state
}

cooling_limit() {
	local limit=$(cat /sys/devices/soc.0/cpu_budget_cool.16/roomage)
	print "Cooling limit" $limit
}

cpu_frequency
cpu_count
scaling_govenor
vcore_voltage
soc_temp
cooling_state
cooling_limit
