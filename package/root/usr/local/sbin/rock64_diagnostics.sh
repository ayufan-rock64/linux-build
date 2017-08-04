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

#thanks to tkaiser for the initial command for this function
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
# because they did an amazing job at making a create diagnostic report! Specifically:

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

	echo -e "### partitions:\n"
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

        echo -e "Searching for info on flash media... "
        get_flash_information >>${Log}
	which iostat >/dev/null 2>&1 && \

	echo -e "\n### Current sysinfo:\n\n"
	which iostat >/dev/null 2>&1 && echo -e "$(iostat -p ALL | grep -v '^loop')\n\n"
	echo -e "$(vmstat -w)\n\n$(free -h)\n\n$(dmesg | tail -n 250)"
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
	echo -e "Running file integrity checks... "
   	VerifyFiles >> ${Log}

	#check network connection
	fping sprunge.us | grep -q alive || \
	(echo "Network/firewall problem detected. Please fix this or upload ${Log} manually." >&2 ; exit 1)

	echo -ne "\nIP obfuscated log uploaded to \c"
	# obfuscate IPv4 addresses somehow but not too much
	cat ${Log} | \
		sed -E 's/([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3}\.)([0-9]{1,3})/XXX.XXX.\3\4/g' \
		| curl -F 'sprunge=<-' http://sprunge.us

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
	echo -e " ${0##*/} ${BOLD}-u${NC} tries to upload diagnostic logs for support purposes"
	echo -e " ${0##*/} ${BOLD}-v${NC} tries to diagnose corrupt packages and files"
	echo -e "\n############################################################################\n"
} # DisplayUsage

ParseOptions() {
	while getopts 'hHlLvVfFmMuUc:C:' c ; do
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

		u|U)
			# upload generated logs for support
			RequireRoot
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
	# $1 is the time in seconds to pause between two prints, defaults to 5 seconds
	# This functions prints out endlessly:
	# - time/date
	# - average 1m load
	# - detailed CPU statistics
	# - Soc temperature if available
	# - PMIC temperature if available
	# TODO: Format output nicely
	LastUserStat=0
	LastNiceStat=0
	LastSystemStat=0
	LastIdleStat=0
	LastIOWaitStat=0
	LastIrqStat=0
	LastSoftIrqStat=0
	LastCpuStatCheck=0

	DisplayHeader="Time        CPU    load %cpu %sys %usr %nice %io %irq"
	CPUs=normal
	[ -f /sys/devices/virtual/thermal/thermal_zone0/temp ] && DisplayHeader="${DisplayHeader}   CPU" || SocTemp='n/a'
	echo -e "${DisplayHeader}\c"
	Counter=0
	while true ; do
		let Counter++
		if [ ${Counter} -eq 15 ]; then
			echo -e "\n${DisplayHeader}\c"
			Counter=0
		fi
		LoadAvg=$(cut -f1 -d" " </proc/loadavg)
		if [ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq ]; then
			CpuFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq) 2>/dev/null
		elif [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
			CpuFreq=$(awk '{printf ("%0.0f",$1/1000); }' </sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) 2>/dev/null
		else
			CpuFreq='n/a'
		fi
		echo -e "\n$(date "+%H:%M:%S"): $(printf "%4s" ${CpuFreq})MHz $(printf "%5s" ${LoadAvg}) $(ProcessStats)\c"
		if [ "X${SocTemp}" != "Xn/a" ]; then
			read SocTemp </sys/devices/virtual/thermal/thermal_zone0/temp
			if [ ${SocTemp} -ge 1000 ]; then
				SocTemp=$(awk '{printf ("%0.1f",$1/1000); }' <<<${SocTemp})
			fi
			echo -e " $(printf "%4s" ${SocTemp})°C\c"
		fi
		sleep ${1:-5}
	done
} # MonitorMode

ProcessStats() {
	if [ -f /tmp/cpustat ]; then
		# RPi-Monitor/Armbianmonitor already running and providing processed values
		set $(awk -F" " '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}' </tmp/cpustat)
		CPULoad=$1
		SystemLoad=$2
		UserLoad=$3
		NiceLoad=$4
		IOWaitLoad=$5
		IrqCombinedLoad=$6
	else
		set $(awk -F" " '/^cpu / {print $2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8}' </proc/stat)
		UserStat=$1
		NiceStat=$2
		SystemStat=$3
		IdleStat=$4
		IOWaitStat=$5
		IrqStat=$6
		SoftIrqStat=$7

		UserDiff=$(( ${UserStat} - ${LastUserStat} ))
		NiceDiff=$(( ${NiceStat} - ${LastNiceStat} ))
		SystemDiff=$(( ${SystemStat} - ${LastSystemStat} ))
		IdleDiff=$(( ${IdleStat} - ${LastIdleStat} ))
		IOWaitDiff=$(( ${IOWaitStat} - ${LastIOWaitStat} ))
		IrqDiff=$(( ${IrqStat} - ${LastIrqStat} ))
		SoftIrqDiff=$(( ${SoftIrqStat} - ${LastSoftIrqStat} ))

		Total=$(( ${UserDiff} + ${NiceDiff} + ${SystemDiff} + ${IdleDiff} + ${IOWaitDiff} + ${IrqDiff} + ${SoftIrqDiff} ))
		CPULoad=$(( ( ${Total} - ${IdleDiff} ) * 100 / ${Total} ))
		UserLoad=$(( ${UserDiff} *100 / ${Total} ))
		SystemLoad=$(( ${SystemDiff} *100 / ${Total} ))
		NiceLoad=$(( ${NiceDiff} *100 / ${Total} ))
		IOWaitLoad=$(( ${IOWaitDiff} *100 / ${Total} ))
		IrqCombinedLoad=$(( ( ${IrqDiff} + ${SoftIrqDiff} ) *100 / ${Total} ))

		LastUserStat=${UserStat}
		LastNiceStat=${NiceStat}
		LastSystemStat=${SystemStat}
		LastIdleStat=${IdleStat}
		LastIOWaitStat=${IOWaitStat}
		LastIrqStat=${IrqStat}
		LastSoftIrqStat=${SoftIrqStat}
	fi
	echo -e "$(printf "%3s" ${CPULoad})%$(printf "%4s" ${SystemLoad})%$(printf "%4s" ${UserLoad})%$(printf "%4s" ${NiceLoad})%$(printf "%4s" ${IOWaitLoad})%$(printf "%4s" ${IrqCombinedLoad})%"

} # ProcessStats

Main "$@"
