#!/bin/bash -e

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
TOOLPATH=${LOCALPATH}/rkbin/tools
EXTLINUXPATH=${LOCALPATH}/build/extlinux
CHIP=""
TARGET=""
SIZE=""
ROOTFS_PATH=""

PATH=$PATH:$TOOLPATH

source $LOCALPATH/build/partitions.sh

usage() {
	echo -e "\nUsage: build/mk-image.sh -c rk3288 -t system -s 4000 -r rk-rootfs-build/linaro-rootfs.img \n"
	echo -e "       build/mk-image.sh -c rk3288 -t boot\n"
}
finish() {
	echo -e "\e[31m MAKE IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

OLD_OPTIND=$OPTIND
while getopts "c:t:s:r:h" flag; do
	case $flag in
		c)
			CHIP="$OPTARG"
			;;
		t)
			TARGET="$OPTARG"
			;;
		s)
			SIZE="$OPTARG"
			if [ $SIZE -le 120 ]; then
				echo -e "\e[31m SYSTEM IMAGE SIZE TOO SMALL \e[0m"
				exit -1
			fi
			;;
		r)
			ROOTFS_PATH="$OPTARG"
			;;
	esac
done
OPTIND=$OLD_OPTIND

if [ ! -e ${EXTLINUXPATH}/${CHIP}.conf ]; then
	CHIP="rk3288"
fi

if [ ! $CHIP ] && [ ! $TARGET ]; then
	usage
	exit
fi

generate_boot_image() {
	BOOT=${OUT}/boot.img
	rm -rf ${BOOT}

	echo -e "\e[36m Generate Boot image start\e[0m"

	# 100 Mb
	mkfs.vfat -n "boot" -S 512 -C ${BOOT} $((100 * 1024))

	mmd -i ${BOOT} ::/extlinux
	mcopy -i ${BOOT} -s ${EXTLINUXPATH}/${CHIP}.conf ::/extlinux/extlinux.conf
	mcopy -i ${BOOT} -s ${OUT}/kernel/* ::

	echo -e "\e[36m Generate Boot image : ${BOOT} success! \e[0m"
}

generate_system_image() {
	SYSTEM=${OUT}/system.img
	rm -rf ${SYSTEM}

	echo "Generate System image : ${SYSTEM} !"

	dd if=/dev/zero of=${SYSTEM} bs=1M count=0 seek=$SIZE

	parted -s ${SYSTEM} mklabel gpt
	parted -s ${SYSTEM} unit s mkpart loader1 ${LOADER1_START} $(expr ${RESERVED1_START} - 1)
	parted -s ${SYSTEM} unit s mkpart reserved1 ${RESERVED1_START} $(expr ${RESERVED2_START} - 1)
	parted -s ${SYSTEM} unit s mkpart reserved2 ${RESERVED2_START} $(expr ${LOADER2_START} - 1)
	parted -s ${SYSTEM} unit s mkpart loader2 ${LOADER2_START} $(expr ${ATF_START} - 1)
	parted -s ${SYSTEM} unit s mkpart atf ${ATF_START} $(expr ${BOOT_START} - 1)
	parted -s ${SYSTEM} unit s mkpart boot ${BOOT_START} $(expr ${ROOTFS_START} - 1)
	parted -s ${SYSTEM} set 6 boot on
	parted -s ${SYSTEM} unit s mkpart root ${ROOTFS_START} 100%

	# burn u-boot
	if [ "$CHIP" == "rk3288" ] || [ "$CHIP" == "rk3036" ]; then
		dd if=${OUT}/u-boot/idbloader.img of=${SYSTEM} seek=${LOADER1_START} conv=notrunc
	elif [ "$CHIP" == "rk3399" ]; then
		dd if=${LOCALPATH}/rkbin/rk33/RK3399MiniLoaderAll_V1.05.bin of=${SYSTEM} seek=${LOADER1_START} conv=notrunc

		dd if=${OUT}/u-boot/uboot.img of=${SYSTEM} seek=${LOADER2_START} conv=notrunc
		dd if=${OUT}/u-boot/trust.img of=${SYSTEM} seek=${ATF_START} conv=notrunc
	elif [ "$CHIP" == "rk3328" ]; then
		dd if=${LOCALPATH}/rkbin/rk33/RK3328MiniLoaderAll_V1.05.bin of=${SYSTEM} seek=${LOADER1_START} conv=notrunc

		dd if=${OUT}/u-boot/uboot.img of=${SYSTEM} seek=${LOADER2_START} conv=notrunc
		dd if=${OUT}/u-boot/trust.img of=${SYSTEM} seek=${ATF_START} conv=notrunc
	fi

	# burn boot image
	if [ ! -e ${OUT}/boot.img ]; then
		echo -e "\e[31m CAN'T FIND BOOT IMAGE \e[0m"
		exit
	fi
	dd if=${OUT}/boot.img of=${SYSTEM} conv=notrunc seek=${BOOT_START}

	# burn rootfs image
	if [ ! -e ${ROOTFS_PATH} ]; then
		echo -e "\e[31m CAN'T FIND ROOTFS IMAGE \e[0m"
		exit
	fi
	dd if=${ROOTFS_PATH} of=${SYSTEM} seek=${ROOTFS_START}
}

if [ "$TARGET" = "boot" ]; then
	generate_boot_image
elif [ "$TARGET" == "system" ]; then
	generate_system_image
fi
