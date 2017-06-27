#!/bin/bash

set -e

if [ "$(id -u)" -ne "0" ]; then
        echo "This script requires root."
        exit 1
fi

print() {
        printf "%-20s: %s %s\n" "$1" "$2 $3" "$4"
}

statprint() {
	local STAT_PATH=/sys/bus/platform/drivers/rk_gmac-dwmac/ff540000.eth/net/eth0/statistics
	local STAT_VALUE=$(cat $STAT_PATH/$1)
	print "$1" $STAT_VALUE
}

all() {
	statprint collisions
	statprint multicast
	statprint rx_bytes
	statprint rx_compressed
	statprint rx_crc_errors
	statprint rx_dropped
	statprint rx_errors
	statprint rx_fifo_errors
	statprint rx_frame_errors
	statprint rx_length_errors
	statprint rx_missed_errors
	statprint rx_over_errors
	statprint rx_packets
	statprint tx_aborted_errors
	statprint tx_bytes
	statprint tx_carrier_errors
	statprint tx_compressed
	statprint tx_dropped
	statprint tx_errors
	statprint tx_fifo_errors
	statprint tx_heartbeat_errors
	statprint tx_packets
	statprint tx_window_errors
}

usage() {
	echo "Usage: $0 [-w] [-h]"
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

