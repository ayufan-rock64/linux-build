#!/bin/bash

echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
for i in 1 2 3 ; do
	echo 4 >/proc/irq/$(awk -F":" "/xhci/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
	echo 8 >/proc/irq/$(awk -F":" "/eth0/ {print \$1}" </proc/interrupts | sed 's/\ //g')/smp_affinity
done
echo 7 >/sys/class/net/eth0/queues/rx-0/rps_cpus
echo 32768 >/proc/sys/net/core/rps_sock_flow_entries
echo 32768 >/sys/class/net/eth0/queues/rx-0/rps_flow_cnt

exit 0
