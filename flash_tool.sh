#!/bin/bash -e

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
TOOLPATH=${LOCALPATH}/rkbin/tool
EXTLINUXPATH=${LOCALPATH}/build/extlinux
CHIP=""
DEVICE=""
IMAGE=""
DEVICE=""
SEEK=""

PATH=$PATH:$TOOLPATH

source $LOCALPATH/build/partitions.sh

usage() {
	echo -e "\nUsage: emmc: build/flash_tool.sh -c rk3288  -p system -i out/system.img  \n"
	echo -e "       sdcard: build/flash_tool.sh -c rk3288  -d /dev/sdb -p system  -i out/system.img \n"
}

finish() {
	echo -e "\e[31m FLASH IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

while getopts "c:t:s:d:p:r:d:i:h" flag
do
	case $flag in
		c)
			CHIP="$OPTARG"
			;;
		d)
			DEVICE="$OPTARG"
			;;
		i)
			IMAGE="$OPTARG"
			if [ ! -e ${IMAGE} ] ; then
				echo -e "\e[31m CAN'T FIND IMAGE \e[0m"
				usage
				exit
			fi
			;;
		p)
			PARTITIONS="$OPTARG"
			BPARTITIONS=`echo $PARTITIONS| tr 'a-z' 'A-Z'`
			SEEK=${BPARTITIONS}_START
			eval SEEK=\$$SEEK

			if [ -n "$(echo $SEEK| sed -n "/^[0-9]\+$/p")" ];then
				echo "PARTITIONS OFFSET: $SEEK sectors."
			else
				echo -e "\e[31m INVAILD PARTITION.\e[0m"
				exit
			fi
			;;
	esac
done

if [ ! $IMAGE ] ; then
	usage
	exit
fi

if [ ! -e ${EXTLINUXPATH}/${CHIP}.conf ] ; then
	CHIP="rk3288"
fi

flash_upgt()
{
	if [ "${CHIP}" == "rk3288" ] ; then
		sudo upgrade_tool db  ${LOCALPATH}/rkbin/rk32/RK3288UbootLoader_V2.30.06.bin
	elif [ "${CHIP}" == "rk3036" ] ; then
		sudo upgrade_tool db  ${LOCALPATH}/rkbin/rk30//RK3036MiniLoaderAll_V2.19.bin
	elif [ "${CHIP}" == "rk3399" ] ; then
		sudo upgrade_tool db  ${LOCALPATH}/rkbin/rk33/RK3399MiniLoaderAll_V1.05.bin
	elif [ "${CHIP}" == "rk3228" ] ; then
		sudo upgrade_tool db  ${LOCALPATH}/rkbin/rk33/RK3328MiniLoaderAll_V1.05.bin
	fi

	sudo upgrade_tool wl ${SEEK} ${IMAGE}

	sudo upgrade_tool rd
}

flash_sdcard()
{
	sudo dd if=${IMAGE} of=${DEVICE} seek=${SEEK} conv=notrunc
}

if [ ! $DEVICE ] ; then
	flash_upgt
else
	flash_sdcard
fi
