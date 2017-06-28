#!/bin/bash

set -e

STAT_PATH=/sys/bus/platform/drivers/rk_gmac-dwmac/ff540000.eth/net/eth0/statistics

print() {
        printf "%-20s: %s %s\n" "$1" "$2 $3" "$4"
}

statprint() {
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
	echo "Usage: $0 [OPTION]"
        echo -e "  -w [time]\tKeep watching, refreshing every 0.5 seconds or as set"
        echo -e "  -h\t\tThis help screen"
}

while getopts ":w:h" opt; do
   case $opt in
      w)
         if [[ $OPTARG =~ ^[0-9]+$ ]]; then
           WATCH=$OPTARG
         fi
         ;;
      h)
         usage
         exit 0
         ;;
      :) #can only be -w with no custom refresh interval
         WATCH=0.5
         ;;
      *)
         echo "Invalid parameter '-$OPTARG'"
         usage
         exit 1
         ;;
   esac
done

if [ -n "$WATCH" ]; then
	exec watch -n$WATCH "$0"
else
	all
fi
