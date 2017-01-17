#!/bin/bash

export ARCH=arm 
export CROSS_COMPILE=arm-linux-gnueabihf-

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
BOARD=$1
DEFCONFIG=""
CHIP=""

finish() {
	echo -e "\e[31m MAKE UBOOT IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

if [ $# != 1 ] ; then
    BOARD=rk3288-evb
fi
OUTBIN=${BOARD}-uboot.bin

[ ! -d ${OUT} ] && mkdir ${OUT}
[ ! -d ${OUT}/u-boot ] && mkdir ${OUT}/u-boot

case ${BOARD} in
	"rk3399-evb")
		DEFCONFIG=evb-rk3399_defconfig
		CHIP="RK3399"
	;;
	"rk3288-evb")
		DEFCONFIG=evb-rk3288_defconfig
		CHIP="RK3288"
	;;
	"fennec")
		DEFCONFIG=fennec-rk3288_defconfig
		CHIP="RK3288"
	;;        
	"miniarm")
		DEFCONFIG=miniarm-rk3288_defconfig
		CHIP="RK3288"
	;;    
	"firefly")
		DEFCONFIG=firefly-rk3288_defconfig
		CHIP="RK3288"
	;;
	"kylin")
		DEFCONFIG=kylin-rk3036_defconfig
		CHIP="RK3036"
	;;
	*)
	echo "board not support in U-boot"
	;;
esac

echo Building U-boot for ${BOARD} board!
echo Using ${DEFCONFIG}

cd ${LOCALPATH}/u-boot
make ${DEFCONFIG} all

if [ "$CHIP "== "RK3288" ] ; then
	tools/mkimage -n rk3288 -T \
		 rksd -d spl/u-boot-spl-dtb.bin u-boot.out
	cat u-boot-dtb.bin >> u-boot.out
	cp u-boot.out ${OUT}/u-boot/	
elif [ "$CHIP" == "RK3036" ] ; then
	tools/mkimage -n rk3036 -T rksd -d spl/u-boot-spl.bin uboot.out
	cat u-boot-dtb.bin >> uboot.out
	cp  uboot.out ${OUT}/u-boot/
elif [ "$CHIP" == "RK3399" ] ; then
	echo "nothing"
fi
