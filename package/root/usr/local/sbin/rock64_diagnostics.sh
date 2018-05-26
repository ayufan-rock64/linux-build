#!/bin/bash
# This script is designed to be a general purpose diagnostic log and testing
# script for the pine64 and related SBC boards. It heavily borrows from code
# used in the Armbian project's armbianmonitor.
#
# Written 2017 Peter Feerick and contributors, released under GPLv3
#

#if user doesn't have permission for /var/log, write to /tmp
if [ -w /var/log ]; then
	Log="/var/log/${0##*/}.log"
else
	Log="/tmp/${0##*/}.log"
fi

VerifyRepairExcludes="/etc/|/boot/|cache|getty|/var/lib/smartmontools/"

Main() {
	# check if stdout is a terminal...
	if test -t 1; then
		# see if it supports colors...
		ncolors=$(tput colors)
		if test -n "$ncolors" && test $ncolors -ge 8; then
			BOLD="$(tput bold)"
			NC='\033[0m' # No Color
			LGREEN='\033[1;32m'
			LRED='\e[0;91m'
		fi
	fi

	[ $# -eq 0 ] && (DisplayUsage ; exit 0)

	ParseOptions "$@"

	exit 0
} # Main

# thanks to tkaiser for the initial command for this function
VerifyFiles() {
	echo -e "\n### file verification:\n"

	OUTPUT=$(dpkg --verify | egrep -v -i "${VerifyRepairExcludes}" | awk -F" /" '{print "/"$2}')

	if [[ -z $OUTPUT ]]; then
		echo -e "${LGREEN}${BOLD}It would appear you don't have any corrupt files or packages!${NC}"
		echo -e "If you still have concerns, use this scripts media test mode"
		echo -e "to do a stress test of your drive/storage device.\n"
	else
		echo -e "${LRED}${BOLD}It appears you *may* have corrupt packages.${NC} If you believe this to be the"
		echo -e "case (and not a customisation that you or a script has applied), re-run this"
		echo -e "script in fix mode to try and fix these packages.\n"

		echo -e "### The following changed from packaged state files were detected:\n"
		echo -e "${OUTPUT}\n"
	fi

} # VerifyFiles

#thanks to tkaiser for the initial command for this function
VerifyAndFixFiles() {
	echo -e "\n### file verification and file/package repair:\n"

	STAGE1=$(dpkg --verify | egrep -v -i "${VerifyRepairExcludes}" | awk -F" /" '{print "/"$2}')

	if [[ -z $STAGE1 ]]; then
		echo -e "${LGREEN}${BOLD}It would appear you don't have any corrupt files or packages!${NC}"
		echo -e "\nIf you are experiencing issues, it is probably best to back"
		echo -e "up your data, and reinstall the OS from a new image.\n"
	else
		echo -e "### The following changed from packaged state files were detected:\n"
		echo -e "${STAGE1}"

		echo -e "\n### Identifying which packages the changed files belong to... "
		STAGE2=$(echo "${STAGE1}" | while read ; do dpkg -S "${REPLY}" | cut -f1 -d: ; done | sort | uniq)

		if [[ -z ${STAGE2} ]]; then
			echo -e "\n\n${LRED}${BOLD}An internal error has occured... Exiting!${NC}"
			exit 1
		else
			echo -e "\nThe following packages will be reinstalled:"
			echo -e "${STAGE2}"

			# test internet connection by poking google
			nc -zw1 google.com 443 >/dev/null 2>&1

			if [[ $? -eq 0 ]]; then
				echo -e "\n### Updating software repositories before package reinstall..."
				apt-get update -qq >/dev/null 2>&1

				echo "${STAGE2}" | while read;
				do
				  	echo -e "Reinstalling package: ${REPLY}"
				  	apt-get -q --reinstall -y install ${REPLY} >/dev/null 2>&1
				done

				echo -e "\n${LGREEN}${BOLD}Process complete.${NC} Reboot your device now and see if the issues that"
				echo -e "were identified have been successfully resolved."
			else
				echo -e "\n${LRED}${BOLD}It appears you don't have an active internet connection!!${NC}\n"
				echo -e "Repair cannot proceed without an internet connection as new/fresh versions of the"
				echo -e "package files are downloaded as part of the repair process. Please resolve the"
				echo -e "network/network issue and then try again. Exiting!\n"

				exit 1
			fi
		fi
	fi
} # VerifyAndFixFiles

# Most of the below has been shameless copied from the Armbian project's armbianmonitor,
# because they did an amazing job at creating a diagnostic report! Specifically:

# https://github.com/armbian/build/blob/master/packages/bsp/armbianmonitor/armbianmonitor-daemon
# https://github.com/armbian/build/blob/master/packages/bsp/armbianmonitor/armbianmonitor
# https://github.com/armbian/build/blob/master/packages/bsp/armhwinfo
GenerateLog() {
	echo -e "\n### dmesg:\n"
	dmesg

	echo -e "\n### meminfo:\n"
	cat /proc/meminfo

	echo -e "\n### ifconfig:\n"
	ifconfig

	echo -e "### lsusb:\n"
	lsusb 2>/dev/null ; echo "" ; lsusb -t 2>/dev/null
	
	lspci >/dev/null 2>&1 && (echo -e "\n### lspci:" ; lspci 2>/dev/null)
	
	echo -e "\n### partitions:\n"
	cat /proc/partitions

	echo -e "\n### df:\n"
	df -h

	echo -e "\n### Installed packages:\n\n$(dpkg -l | egrep "linux-|openmediavault")"

	echo -e "\n### Loaded modules:\n\n$(lsmod)"

        if [[ $(dpkg-query -W -f='${Status}' linux-pine64-package 2>/dev/null | grep -c "ok installed") == "1" ]]; then
                echo -e "\n### linux-pine64-package version:\n"
                apt-cache policy linux-pine64-package
        fi

        if [[ $(dpkg-query -W -f='${Status}' linux-rock64-package 2>/dev/null | grep -c "ok installed") == "1" ]]; then
                echo -e "\n### linux-rock64-package version:\n"
                apt-cache policy linux-rock64-package
        fi

	echo -e "\n### Kernel version:\n"
	uname -a

	get_flash_information
	which iostat >/dev/null 2>&1 && \
		echo -e "\n### Current sysinfo:\n"
	which iostat >/dev/null 2>&1 && echo -e "$(iostat -p ALL | grep -v '^loop')\n\n"
	echo -e "$(vmstat -w)\n\n$(free -h)"
} # GenerateLog

CheckCard() {
	if [ "$(id -u)" = "0" ]; then
		echo "Checking disks is not permitted as root or through sudo. Exiting" >&2
		exit 1
	fi

	if [ ! -d "$1" ]; then
		echo "\"$1\" does not exist or is no directory. Exiting" >&2
		exit 1
	fi
	TargetDir="$1"

	# check requirements
	which f3write >/dev/null 2>&1 || MissingTools=" f3"
	which iozone >/dev/null 2>&1 || MissingTools="${MissingTools} iozone3"
	if [ "X${MissingTools}" != "X" ]; then
		echo "Some tools are missing, please do a \"sudo apt-get -f -y install${MissingTools}\" to install them, and try again" >&2
		exit 1
	fi

	# check provided path
	Device="$(GetDevice "$1")"
	set ${Device}
	DeviceName=$1
	FileSystem=$2
	echo "${DeviceName}" | grep -q "mmcblk0" || echo -e "\n${BOLD}NOTE:${NC} It seems you're actually testing ${DeviceName} (${FileSystem})\n"

	TestDir="$(mktemp -d "${TargetDir}/cardtest.XXXXXX" || exit 1)"
	date "+%s" >"${TestDir}/.starttime" || exit 1
	trap "rm -rf \"${TestDir}\" ; exit 0" 0 1 2 3 15
	LogFile="$(mktemp /tmp/armbianmonitor_checks_${DeviceName##*/}_${FileSystem}.XXXXXX)"

	# start actual test, create a small file for some space reserve
	fallocate -l 32M "${TestDir}/empty.32m" 2>/dev/null || dd if=/dev/zero of="${TestDir}/empty.32m" bs=1M count=32 status=noxfer >/dev/null 2>&1
	ShowWarning=false

	# Start writing
	echo -e "Starting to fill ${DeviceName} with test patterns, please be patient this might take a very long time"
	f3write "${TestDir}" | tee "${LogFile}"
	touch "${TestDir}/.starttime" || ShowDeviceWarning
	rm "${TestDir}/empty.32m"

	# Start verify
	echo -e "\nNow verifying the written data:"
	echo "" >>"${LogFile}"
	f3read "${TestDir}" | tee -a "${LogFile}"
	touch "${TestDir}/.starttime" || ShowDeviceWarning
	rm "${TestDir}/"*.h2w
	echo -e "\nStarting iozone tests. Be patient, this can take a very long time to complete:"
	echo "" >>"${LogFile}"
	cd "${TestDir}"
	iozone -e -I -a -s 100M -r 4k -r 512k -r 16M -i 0 -i 1 -i 2 | tee -a "${LogFile}"
	touch "${TestDir}/.starttime" || ShowDeviceWarning
	echo -e "\n${BOLD}The results from testing ${DeviceName} (${FileSystem}):${NC}"
	egrep "Average|Data" "${LogFile}" | sort -r
	echo "                                            random    random"
	echo -e "reclen    write  rewrite    read    reread    read     write\c"
	awk -F"102400  " '/102400/ {print $2}' <"${LogFile}"

	# check health
	echo -e "\n${BOLD}Health summary: \c"
	egrep -q "Read-only|Input/output error" "${LogFile}" && (echo -e "${LRED}${BOLD}${DeviceName} failed${NC}" ; exit 0)
	grep -q "Data LOST: 0.00 Byte" "${LogFile}" && echo -e "${LGREEN}OK" || \
		(echo -e "${LRED}${BOLD}${DeviceName} failed. Replace it as soon as possible!" ; \
		grep -A3 "^Data LOST" "${LogFile}")

	# check performance
	RandomSpeed=$(awk -F" " '/102400       4/ {print $7"\t"$8}' <"${LogFile}")
	if [ "X${RandomSpeed}" != "X" ]; then
		# Only continue when we're able to read out iozone results
		set ${RandomSpeed}
		RandomReadSpead=$1
		RandomWriteSpead=$2
		ReadSpeed=$(awk -F" " '/Average reading speed/ {print $4"\t"$5}' <"${LogFile}")
		set ${ReadSpeed}
		if [ "X$2" = "XMB/s" ]; then
			RawReadSpead=$(echo "$1 * 1000" | bc -s | cut -f1 -d.)
		else
			RawReadSpead$(echo "$1" | cut -f1 -d.)
		fi
		echo -e "\n${NC}${BOLD}Performance summary:${NC}\nSequential reading speed:$(printf "%6s" $1) $2 \c"
		[ ${RawReadSpead} -le 2500 ] && Exclamation="${LRED}${BOLD}way " || Exclamation=""
		[ ${RawReadSpead} -le 5000 ] && Exclamation="${Exclamation}${BOLD}too "
		[ ${RawReadSpead} -le 7500 ] && echo -e "(${Exclamation}low${NC})\c"
		echo "${Exclamation}" | grep -q "too" && ShowWarning=true
		echo -e "\n 4K random reading speed:$(printf "%6s" ${RandomReadSpead}) KB/s \c"
		[ ${RandomReadSpead} -le 700 ] && Exclamation="${LRED}${BOLD}way " || Exclamation=""
		[ ${RandomReadSpead} -le 1400 ] && Exclamation="${Exclamation}${BOLD}too "
		[ ${RandomReadSpead} -le 2500 ] && echo -e "(${Exclamation}low${NC})\c"
		echo "${Exclamation}" | grep -q "too" && ShowWarning=true
		WriteSpeed=$(awk -F" " '/Average writing speed/ {print $4"\t"$5}' <"${LogFile}")
		set ${WriteSpeed}
		if [ "X$2" = "XMB/s" ]; then
			RawWriteSpeed=$(echo "$1 * 1000" | bc -s | cut -f1 -d.)
		else
			RawWriteSpeed=$(echo "$1" | cut -f1 -d.)
		fi
		echo -e "\nSequential writing speed:$(printf "%6s" $1) $2 \c"
		[ ${RawWriteSpeed} -le 2500 ] && Exclamation="${LRED}${BOLD}way " || Exclamation=""
		[ ${RawWriteSpeed} -le 4000 ] && Exclamation="${Exclamation}${BOLD}too "
		[ ${RawWriteSpeed} -le 6000 ] && echo -e "(${Exclamation}low${NC})\c"
		echo "${Exclamation}" | grep -q "too" && ShowWarning=true
		echo -e "\n 4K random writing speed:$(printf "%6s" ${RandomWriteSpead}) KB/s \c"
		[ ${RandomWriteSpead} -le 400 ] && Exclamation="${LRED}${BOLD}way " || Exclamation=""
		[ ${RandomWriteSpead} -le 750 ] && Exclamation="${Exclamation}${BOLD}too "
		[ ${RandomWriteSpead} -lt 1000 ] && echo -e "(${Exclamation}low${NC})\c"
		echo "${Exclamation}" | grep -q "too" && ShowWarning=true
		if [ "X${ShowWarning}" = "Xtrue" ]; then
			echo -e "\n\n${BOLD}The device you tested seems to perform too slow to be used with pine64."
			echo -e "This applies especially to desktop images where slow storage is responsible"
			echo -e "for sluggish behaviour. If you want to have fun with your device do NOT use"
			echo -e "this media to put the OS image or the user homedirs on.${NC}\c"
		fi
		echo -e "\n\nTo interpret the results above correctly or search for better storage
alternatives please refer to http://oss.digirati.com.br/f3/ and also
http://www.jeffgeerling.com/blogs/jeff-geerling/raspberry-pi-microsd-card
and http://thewirecutter.com/reviews/best-microsd-card/"
	fi
} # CheckCard

GetDevice() {
	TestPath=$(findmnt "$1" | awk -F" " '/\/dev\// {print $2"\t"$3}')
	if [[ -z ${TestPath} && -n "${1%/*}" ]]; then
		GetDevice "${1%/*}"
	elif [[ -z ${TestPath} && -z "${1%/*}" ]]; then
		findmnt / | awk -F" " '/\/dev\// {print $2"\t"$3}'
	else
		echo "${TestPath}"
	fi
} # GetDevice

get_flash_information() {
	# http://www.bunniestudios.com/blog/?page_id=1022
	find /sys -name oemid | while read Device ; do
		DeviceNode="${Device%/*}"
		DeviceName="${DeviceNode##*/}"
		echo -e "\n### ${DeviceName} info:\n"
		find "${DeviceNode}" -maxdepth 1 -type f | while read ; do
			NodeName="${REPLY##*/}"
			echo -e "$(printf "%20s" ${NodeName}): $(cat "${DeviceNode}/${NodeName}" | tr '\n' " ")"
		done
	done
} # get_flash_information

UploadSupportLogs() {
	#prevent colour escape sequences in log
	BOLD=''
	NC=''
	LGREEN=''
	LRED=''

	#check requirements
	which fping >/dev/null 2>&1 || MissingTools=" fping"
	which curl >/dev/null 2>&1 || MissingTools="${MissingTools} curl"
	which iostat >/dev/null 2>&1 || MissingTools="${MissingTools} sysstat"

	if [ "X${MissingTools}" != "X" ]; then
		echo -e "Some tools are missing, installing: ${MissingTools}" >&2
		apt-get -f -qq -y install ${MissingTools} >/dev/null 2>&1
	fi

	echo -e "Generating diagnostic logs... "
	GenerateLog > ${Log}
   	[[ -n ${VERIFY} ]] && (echo -e "Running file integrity checks... " ; VerifyFiles >> ${Log})

	#check network connection
	fping ix.io | grep -q alive || \
	(echo "Network/firewall problem detected. Please fix this or upload ${Log} manually." >&2 ; exit 1)

	echo -ne "\nIP obfuscated log uploaded to \c"
	# obfuscate IPv4 addresses somehow but not too much
	cat ${Log} | \
		sed -E 's/([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3})/XXX.XXX.\3\4/g' \
		| curl -F 'f:1=<-' http://ix.io

	echo -e "Please post the above URL on the forum where you've been asked for it."
} # UploadSupportLogs

RequireRoot() {
	if [ "$(id -u)" != "0" ]; then
		echo "This function requires root privleges - run as root or through sudo. Exiting" >&2
		exit 1
	fi
} # RequireRoot

DisplayUsage() {
	echo -e "\nUsage: ${BOLD}${0##*/} [-h] [-c \$path] [-f] [-l] [-L] [-m] [-u] [-v]${NC}\n"
	echo -e "############################################################################"
	echo -e "\n Use ${BOLD}${0##*/}${NC} for the following tasks:\n"
	echo -e " ${0##*/} ${BOLD}-c /path/to/test${NC} performs disk health/performance tests"
	echo -e " ${0##*/} ${BOLD}-f${NC} tries to fix detected corrupt packages"
	echo -e " ${0##*/} ${BOLD}-l${NC} outputs diagnostic logs to the screen via less"
	echo -e " ${0##*/} ${BOLD}-L${NC} outputs diagnostic logs to the screen as is"
	echo -e " ${0##*/} ${BOLD}-m${NC} provides simple CLI monitoring"
	echo -e " ${0##*/} ${BOLD}-n${NC} provides simple CLI network monitoring"
	echo -e " ${0##*/} ${BOLD}-u${NC} tries to upload diagnostic logs for support purposes"
	echo -e " ${0##*/} ${BOLD}-v${NC} tries to diagnose corrupt packages and files"
	echo -e "\n############################################################################\n"
} # DisplayUsage

ParseOptions() {
	while getopts 'hHlLvVfFmMnNuUc:C:' c ; do
	case ${c} in
		h|H)
			# display usage info
			DisplayUsage
			exit 0
			;;

		l)
			# generate logs and pipe to screen via less
			GenerateLog | less
			exit 0
			;;

		L)
			# generate logs and output to display
			GenerateLog
			exit 0
			;;

		v|V)
			# file verification mode
			RequireRoot
			VerifyFiles
			exit 0
			;;

		f|F)
			# file verification and repair mode
			RequireRoot
			VerifyAndFixFiles
			exit 0
			;;

		m|M)
			# monitoring mode
			echo -e "Stop monitoring using [ctrl]-[c]"
			MonitorMode
			exit 0
			;;

		n|N)
			# network monitoring mode
			echo -e "Stop monitoring using [ctrl]-[c]"
			NetworkMonitorMode
			exit 0
			;;

		u)
			# upload generated logs for support
			RequireRoot
			UploadSupportLogs
			exit 0
			;;

		U)
			# verify files and upload generated logs for support
			RequireRoot
			export VERIFY=TRUE
			UploadSupportLogs
			exit 0
			;;
			
		c|C)
			# check card mode
			CheckCard "${OPTARG}"
			exit 0
			;;

	esac
	done
} # ParseOptions

MonitorMode() {
	# This functions prints out endlessly:
	# - time/date
	# - average 1m load
	# - detailed CPU statistics
	# - Soc temperature if available

	# Allow script to return back to another calling utility when stopped by [ctrl]-[c]
	trap "echo ; exit 0" 0 1 2 3 15
	
	# Try to renice to 19 to not interfere with OS behaviour
	renice 19 $BASHPID >/dev/null 2>&1

	LastUserStat=0
	LastNiceStat=0
	LastSystemStat=0
	LastIdleStat=0
	LastIOWaitStat=0
	LastIrqStat=0
	LastSoftIrqStat=0
	LastCpuStatCheck=0
	LastTotal=0

	SleepInterval=5

	if [ -f /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq ]; then
		DisplayHeader="Time       big.LITTLE   load %cpu %sys %usr %nice %io %irq"
		CPUs=biglittle
	elif [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq ]; then
		DisplayHeader="Time        CPU    load %cpu %sys %usr %nice %io %irq"
		CPUs=normal
	else
		DisplayHeader="Time      CPU n/a    load %cpu %sys %usr %nice %io %irq"
		CPUs=notavailable
	fi

	[ -f /sys/devices/virtual/thermal/thermal_zone0/temp ] && DisplayHeader="${DisplayHeader}   CPU" || SocTemp='n/a'
	[ -f /sys/devices/virtual/thermal/cooling_device0/cur_state ] \
		&& DisplayHeader="${DisplayHeader}  C.St." || CoolingState='n/a'
	echo -e "Stop monitoring using [ctrl]-[c]"
	echo -e "${DisplayHeader}"
	Counter=0
	while true ; do
		if [ "$c" == "m" ]; then
			let Counter++
			if [ ${Counter} -eq 15 ]; then
				echo -e "\n${DisplayHeader}\c"
				Counter=0
			fi
		elif [ "$c" == "s" ]; then
			# internal mode for debug log upload
			let Counter++
			if [ ${Counter} -eq 6 ]; then
				exit 0
			fi
		else
			printf "\x1b[1A"
		fi
		LoadAvg=$(cut -f1 -d" " </proc/loadavg)
		case ${CPUs} in
			biglittle)
				BigFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq) 2>/dev/null
				LittleFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq) 2>/dev/null
				ProcessStats
				echo -e "\n$(date "+%H:%M:%S"): $(printf "%4s" ${BigFreq})/$(printf "%4s" ${LittleFreq})MHz $(printf "%5s" ${LoadAvg}) ${procStats}\c"
				;;
			normal)
				CpuFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq) 2>/dev/null
				ProcessStats
				echo -e "\n$(date "+%H:%M:%S"): $(printf "%4s" ${CpuFreq})MHz $(printf "%5s" ${LoadAvg}) ${procStats}\c"
				;;
			notavailable)
				ProcessStats
				echo -e "\n$(date "+%H:%M:%S"):   ---     $(printf "%5s" ${LoadAvg}) ${procStats}\c"
				;;
		esac
		if [ "X${SocTemp}" != "Xn/a" ]; then
			SocTemp=$(awk '{printf ("%0.1f",$1/1000); }' </sys/devices/virtual/thermal/thermal_zone0/temp)
			echo -e " $(printf "%4s" ${SocTemp})°C\c"
		fi
		[ "X${CoolingState}" != "Xn/a" ] && printf "  %d/%d" $(cat /sys/devices/virtual/thermal/cooling_device0/cur_state) $(cat /sys/devices/virtual/thermal/cooling_device0/max_state)
		[ "$c" == "s" ] && sleep 0.3 || sleep ${SleepInterval}
	done
} # MonitorMode

ProcessStats() {
	procStatLine=(`sed -n 's/^cpu\s//p' /proc/stat`)
	UserStat=${procStatLine[0]}
	NiceStat=${procStatLine[1]}
	SystemStat=${procStatLine[2]}
	IdleStat=${procStatLine[3]}
	IOWaitStat=${procStatLine[4]}
	IrqStat=${procStatLine[5]}
	SoftIrqStat=${procStatLine[6]}

	Total=0
	for eachstat in ${procStatLine[@]}; do
		Total=$(( ${Total} + ${eachstat} ))
	done

	UserDiff=$(( ${UserStat} - ${LastUserStat} ))
	NiceDiff=$(( ${NiceStat} - ${LastNiceStat} ))
	SystemDiff=$(( ${SystemStat} - ${LastSystemStat} ))
	IOWaitDiff=$(( ${IOWaitStat} - ${LastIOWaitStat} ))
	IrqDiff=$(( ${IrqStat} - ${LastIrqStat} ))
	SoftIrqDiff=$(( ${SoftIrqStat} - ${LastSoftIrqStat} ))
	
	diffIdle=$(( ${IdleStat} - ${LastIdleStat} ))
	diffTotal=$(( ${Total} - ${LastTotal} ))
	diffX=$(( ${diffTotal} - ${diffIdle} ))
	CPULoad=$(( ${diffX}* 100 / ${diffTotal} ))
	UserLoad=$(( ${UserDiff}* 100 / ${diffTotal} ))
	SystemLoad=$(( ${SystemDiff}* 100 / ${diffTotal} ))
	NiceLoad=$(( ${NiceDiff}* 100 / ${diffTotal} ))
	IOWaitLoad=$(( ${IOWaitDiff}* 100 / ${diffTotal} ))
	IrqCombined=$(( ${IrqDiff} + ${SoftIrqDiff} ))
	IrqCombinedLoad=$(( ${IrqCombined}* 100 / ${diffTotal} ))

	LastUserStat=${UserStat}
	LastNiceStat=${NiceStat}
	LastSystemStat=${SystemStat}
	LastIdleStat=${IdleStat}
	LastIOWaitStat=${IOWaitStat}
	LastIrqStat=${IrqStat}
	LastSoftIrqStat=${SoftIrqStat}
	LastTotal=${Total}
	procStats=$(echo -e "$(printf "%3s" ${CPULoad})%$(printf "%4s" ${SystemLoad})%$(printf "%4s" ${UserLoad})%$(printf "%4s" ${NiceLoad})%$(printf "%4s" ${IOWaitLoad})%$(printf "%4s" ${IrqCombinedLoad})%")
} # ProcessStats

NetworkMonitorMode() {	
	# Allow script to return back to another calling utility when stopped by [ctrl]-[c]
	trap "echo ; exit 0" 0 1 2 3 15
	
	# Try to renice to 19 to not interfere with OS behaviour
	renice 19 $BASHPID >/dev/null 2>&1
	
	# Install bc if not present
	which bc >/dev/null 2>&1 || apt-get -f -qq -y install bc >/dev/null 2>&1

	timerStart
	kickAllStatsDown
	iface=$(route -n | egrep UG | egrep -o "[a-zA-Z0-9]*$")
	
	printf "\nruntime network statistics: $(uname -n)\n"
	printf "[tap 'd' to display column headings]\n"
	printf "[tap 'z' to reset counters]\n"
	printf "[use <ctrl-c> to exit]\n"
	printf "[bps: bits/s, Mbps: megabits/s, pps: packets/s, MB: megabytes]\n\n"
	printf "%-11s %-66s          %-66s\n" $(echo -en "$iface rx.stats____________________________________________________________ tx.stats____________________________________________________________")
	printf "%-11s %-11s %-11s \u01B0.%-11s %-11s \u01B0.%-11s \u01A9.%-11s %-11s %-11s \u01B0.%-11s %-11s \u01B0.%-11s \u01A9.%-11s\n\n" $(echo -en "count bps Mbps Mbps pps pps MB bps Mbps Mbps pps pps MB")
	
	while true; do
		nss=(`sed -n 's/'$iface':\s//p' /proc/net/dev`)
		rxB=${nss[0]}
		rxP=${nss[1]}
		txB=${nss[8]}
		txP=${nss[9]}
		drxB=$(( ${rxB} - ${prxB} ))
		drxb=$(( ${drxB}* 8 ))
		drxmb=$(echo "scale=2;$drxb/1000000"|bc)
		drxP=$(( ${rxP} - ${prxP}  ))
		dtxB=$(( ${txB} - ${ptxB} ))
		dtxb=$(( ${dtxB}* 8 ))
		dtxmb=$(echo "scale=2;$dtxb/1000000"|bc)
		dtxP=$(( ${txP} - ${ptxP} ))
		if [ "$cnt" != "0" ]; then
			if [ "$c" == "N" ]; then
				printf "\x1b[1A"
			fi
			srxb=$(( ${srxb} + ${drxb} ))
			stxb=$(( ${stxb} + ${dtxb} ))
			srxB=$(( ${srxB} + ${drxB} ))
			stxB=$(( ${stxB} + ${dtxB} ))
			srxP=$(( ${srxP} + ${drxP} ))
			stxP=$(( ${stxP} + ${dtxP} ))
			srxMB=$(echo "scale=2;$srxB/1024^2"|bc)
			stxMB=$(echo "scale=2;$stxB/1024^2"|bc)
			arxb=$(echo "scale=2;$srxb/$cnt"|bc)
			atxb=$(echo "scale=2;$stxb/$cnt"|bc)
			arxmb=$(echo "scale=2;$arxb/1000000"|bc)
			atxmb=$(echo "scale=2;$atxb/1000000"|bc)
			arxP=$(echo "scale=0;$srxP/$cnt"|bc)
			atxP=$(echo "scale=0;$stxP/$cnt"|bc)
			printf "%-11s %-11s %-11s   %-11s %-11s   %-11s   %-11s %-11s %-11s   %-11s %-11s   %-11s   %-11s\n" $(echo -en "$cnt $drxb $drxmb $arxmb $drxP $arxP $srxMB $dtxb $dtxmb $atxmb $dtxP $atxP $stxMB")
		fi
		prxB="$rxB"
		prxP="$rxP"
		ptxB="$txB"
		ptxP="$txP"
		let cnt++
		timerShut
		read -n1 -s -t$procSecs zeroAll
		timerStart
		if [ "$zeroAll" == 'z' ]; then
			kickAllStatsDown
		fi
		if [ "$zeroAll" == 'd' ]; then
			scrollingHeader
		fi
	done
}

scrollingHeader() {
	printf "%-11s %-66s          %-66s\n" $(echo -en "$iface rx.stats____________________________________________________________ tx.stats____________________________________________________________")
	printf "%-11s %-11s %-11s \u01B0.%-11s %-11s \u01B0.%-11s \u01A9.%-11s %-11s %-11s \u01B0.%-11s %-11s \u01B0.%-11s \u01A9.%-11s\n\n" $(echo -en "count bps Mbps Mbps pps pps MB bps Mbps Mbps pps pps MB")
}

timerStart() {
	read st0 st1 < <(date +'%s %N')
}

timerShut() {
	read sh0 sh1 < <(date +'%s %N')
	jusquaQuand=$(echo "scale=2;($sh0-$st0)*1000000000+($sh1-$st1)"|bc)
	procSecs=$(echo "scale=2;(1000000000-$jusquaQuand)/1000000000"|bc)
	if [ "$rf1" == "debug" ]; then
		printf "time controller adjustment: $procSecs\n"
		if [ "$c" == "N" ]; then
			printf "\x1b[1A"
		fi
	fi
}

kickAllStatsDown() {
	prxB=0
	prxP=0
	ptxB=0
	ptxP=0
	srxb=0
	stxb=0
	srxB=0
	stxB=0
	srxMB=0
	stxMB=0
	srxP=0
	stxP=0
	cnt=0
}

Main "$@"
