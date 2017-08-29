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

Add_USB_Quirks() {
	Quirksfile=/etc/modprobe.d/rk3328-usb-storage-quirks.conf
	if [ ! -f ${Quirksfile} ]; then
		# UAS blacklist Norelsys NS1068X and NS1066X
		echo "options usb-storage quirks=0x2537:0x1066:u,0x2537:0x1068:u" >${Quirksfile}
		chmod 644 ${Quirksfile}
	fi

	# check for connected Seagate or WD HDD enclosures and blacklist them all
	lsusb | awk -F" " '{print "0x"$6}' | sed 's/:/:0x/' | sort | uniq | while read ; do
		case ${REPLY} in
			"0x0bc2:"*|"0x1058:"*)
				grep -q "${REPLY}" ${Quirksfile} || sed -i "1 s/\$/,${REPLY}:u/" ${Quirksfile}
				;;
		esac
	done

	NeedUpate="$(find ${Quirksfile} -mtime 0)"
	if [ "X${NeedUpate}" = "X${Quirksfile}" ]; then
		update-initramfs -u
	fi
}

Tweak_Ondemand_Governor &
Enable_RPS_and_tweak_IRQ_Affinity &
Add_USB_Quirks &

exit 0
