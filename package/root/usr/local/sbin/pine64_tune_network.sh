#!/bin/sh
#
# If you want to use this, call it from /etc/rc.local.

set -ex

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 32768 > /proc/sys/net/core/rps_sock_flow_entries
echo 32768 > /sys/class/net/eth0/queues/rx-0/rps_flow_cnt
echo 2 > /sys/class/net/eth0/queues/rx-0/rps_cpus
echo 1-2 > /proc/irq/114/smp_affinity_list
echo 3 > /proc/irq/92/smp_affinity_list

sysctl -w net.core.rmem_max=26214400
sysctl -w net.core.wmem_max=26214400
sysctl -w net.core.rmem_default=514400
sysctl -w net.core.wmem_default=514400
sysctl -w net.ipv4.tcp_rmem='10240 87380 26214400'
sysctl -w net.ipv4.tcp_wmem='10240 87380 26214400'
sysctl -w net.ipv4.udp_rmem_min=131072
sysctl -w net.ipv4.udp_wmem_min=131072
sysctl -w net.ipv4.tcp_timestamps=1
sysctl -w net.ipv4.tcp_window_scaling=1
sysctl -w net.ipv4.tcp_sack=1
sysctl -w net.core.optmem_max=65535
sysctl -w net.core.netdev_max_backlog=5000
