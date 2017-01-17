#!/bin/bash -e

export ARCH=arm 
export CROSS_COMPILE=arm-linux-gnueabihf-

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
BOARD=$1
DEFCONFIG=""
DTB=""
KERNELIMAGE=""
CHIP=""

finish() {
	echo -e "\e[31m MAKE KERNEL IMAGE FAILED.\e[0m"
	exit -1
}
trap finish ERR

if [ $# != 1 ] ; then
   	BOARD=rk3288-evb
fi

[ ! -d ${OUT} ] && mkdir ${OUT}
[ ! -d ${OUT}/kernel ] && mkdir ${OUT}/kernel

case ${BOARD} in
	"rk3399-evb")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3399-sapphire-excavator-linux.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
		CHIP="RK3399"
	;;
	"rk3328-evb")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3328-evb.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
		CHIP="RK3328"
	;;
	"rk3288-evb")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3288-evb-act8846.dtb
		CHIP="RK3288"
	;;
	"firefly")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3288-firefly.dtb
		CHIP="RK3288"
                ;;
	"fennec")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3288-fennec.dtb
		CHIP="RK3288"
	;; 
	"miniarm")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3288-miniarm.dtb
		CHIP="RK3288"
	;; 
	"kylin")
		DEFCONFIG=rockchip_linux_defconfig
		DTB=rk3036-kylin.dtb
		CHIP="RK3036"
	;;              
	*)
	echo "board '${BOARD}' not supported!"
	return
	;;
esac

echo Building kernel for ${BOARD} board!
echo Using ${DEFCONFIG}

cd ${LOCALPATH}/kernel
make ${DEFCONFIG}
make -j8

if [ $ARCH == "arm" ] ; then
	cp ${LOCALPATH}/kernel/arch/arm/boot/zImage ${OUT}/kernel/
	cp ${LOCALPATH}/kernel/arch/arm/boot/dts/${DTB} ${OUT}/kernel/
else
	cp ${LOCALPATH}/kernel/arch/arm64/boot/Image ${OUT}/kernel/
	cp ${LOCALPATH}/kernel/arch/arm64/boot/dts/rockchip/${DTB} ${OUT}/kernel/
fi


