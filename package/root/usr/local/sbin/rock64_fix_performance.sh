#!/bin/bash

# Taken from: https://forum.armbian.com/index.php?/topic/3953-preview-generate-omv-images-for-sbc-with-armbian/#comment-34596
# with some additions to better deal with UAS incapable USB-to-SATA bridges.

export PATH=/usr/sbin:/usr/bin:/sbin:/bin

Tweak_Ondemand_Governor() {
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
}

Enable_RPS_and_tweak_IRQ_Affinity() {
	for i in 1 2 3 ; do
		echo 2 >/proc/irq/$(awk -F":" "/ehci/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
		echo 2 >/proc/irq/$(awk -F":" "/ohci/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
		echo 4 >/proc/irq/$(awk -F":" "/xhci/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
		echo 8 >/proc/irq/$(awk -F":" "/eth0/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
	done
	echo 7 >/sys/class/net/eth0/queues/rx-0/rps_cpus
	echo 32768 >/proc/sys/net/core/rps_sock_flow_entries
	echo 32768 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt
}

Tweak_Ondemand_Governor
Enable_RPS_and_tweak_IRQ_Affinity

exit 0
