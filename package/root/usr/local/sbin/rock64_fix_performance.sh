#!/bin/bash

# Taken from: https://forum.armbian.com/index.php?/topic/3953-preview-generate-omv-images-for-sbc-with-armbian/#comment-34596

set -x

# echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

echo ondemand >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

sleep 0.1

pushd /sys/devices/system/cpu
for i in cpufreq/ondemand cpu0/cpufreq/ondemand cpu4/cpufreq/ondemand ; do
	if [ -d $i ]; then
		echo 1 >${i}/io_is_busy
		echo 25 >${i}/up_threshold
		echo 10 >${i}/sampling_down_factor
	fi
done
popd

for i in 1 2 3 ; do
	echo 4 >/proc/irq/$(awk -F":" "/xhci/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
	echo 8 >/proc/irq/$(awk -F":" "/eth0/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
done
echo 7 >/sys/class/net/eth0/queues/rx-0/rps_cpus
echo 32768 >/proc/sys/net/core/rps_sock_flow_entries
echo 32768 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt

exit 0
