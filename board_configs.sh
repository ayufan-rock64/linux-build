#!/bin/bash -e

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

BOARD=$1
DEFCONFIG=""
DTB=""
KERNELIMAGE=""
CHIP=""
UBOOT_DEFCONFIG=""

case ${BOARD} in
	"rk3399-evb")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=evb-rk3399_defconfig
		DTB=rk3399-sapphire-excavator-linux.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
		CHIP="RK3399"
	;;
	"rk3328-evb")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=evb-rk3328_defconfig
		DTB=rk3328-evb.dtb
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
		CHIP="RK3328"
	;;
	"rk3288-evb")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=evb-rk3288_defconfig
		DTB=rk3288-evb-act8846.dtb
		CHIP="RK3288"
	;;
	"firefly")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=firefly-rk3288_defconfig
		DTB=rk3288-firefly.dtb
		CHIP="RK3288"
    ;;
	"fennec")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=fennec-rk3288_defconfig
		DTB=rk3288-fennec.dtb
		CHIP="RK3288"
	;;
	"miniarm")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=miniarm-rk3288_defconfig
		DTB=rk3288-miniarm.dtb
		CHIP="RK3288"
	;;
	"kylin")
		DEFCONFIG=rockchip_linux_defconfig
		UBOOT_DEFCONFIG=kylin-rk3036_defconfig
		DTB=rk3036-kylin.dtb
		CHIP="RK3036"
	;;
	*)
	echo "board '${BOARD}' not supported!"
	exit -1
	;;
esac
