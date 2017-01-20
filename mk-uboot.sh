#!/bin/bash

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
TOOLPATH=${LOCALPATH}/rkbin/tool
BOARD=$1

PATH=$PATH:$TOOLPATH

finish() {
	echo -e "\e[31m MAKE UBOOT IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

if [ $# != 1 ] ; then
    BOARD=rk3288-evb
fi

[ ! -d ${OUT} ] && mkdir ${OUT}
[ ! -d ${OUT}/u-boot ] && mkdir ${OUT}/u-boot

source $LOCALPATH/build/board_configs.sh $BOARD

if [ $? -ne 0 ]; then
	exit
fi

echo Building U-boot for ${BOARD} board!
echo Using ${UBOOT_DEFCONFIG}

cd ${LOCALPATH}/u-boot
make ${UBOOT_DEFCONFIG} all

if [ "${CHIP}" == "RK3288" ] ; then
	tools/mkimage -n rk3288 -T \
		 rksd -d spl/u-boot-spl-dtb.bin u-boot.out
	cat u-boot-dtb.bin >> u-boot.out
	cp u-boot.out ${OUT}/u-boot/
elif [ "${CHIP}" == "RK3036" ] ; then
	tools/mkimage -n rk3036 -T rksd -d spl/u-boot-spl.bin uboot.out
	cat u-boot-dtb.bin >> uboot.out
	cp  uboot.out ${OUT}/u-boot/
elif [ "${CHIP}" == "RK3399" ] ; then
	loaderimage --pack --uboot ./u-boot-dtb.bin uboot.img
	$TOOLPATH/trust_merger $TOOLPATH/RK3399TRUST.ini

	cp  uboot.img ${OUT}/u-boot/
	cp  trust.img ${OUT}/u-boot/
elif [ "${CHIP}" == "RK3328" ] ; then
	loaderimage --pack --uboot ./u-boot-dtb.bin uboot.img
	$TOOLPATH/trust_merger $TOOLPATH/RK3328TRUST.ini

	cp  uboot.img ${OUT}/u-boot/
	cp  trust.img ${OUT}/u-boot/
fi
