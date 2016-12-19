#!/bin/bash -e

LOCALPATH=$(pwd)
OUT=${LOCALPATH}/out
BOARD=$1
OPP=$2
DEFCONFIG=""
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
		DTB=rk3399-sapphire-excavator-linux.dtb
		CHIP="RK3399"
	;;
	"rk3288-evb")
		DTB=rk3288-evb-act8846.dtb
		CHIP="RK3288"
	;;
	"firefly")
		DTB=rk3288-firefly.dtb
		CHIP="RK3288"
                ;;
	"fennec")
		DTB=rk3288-fennec.dtb
		CHIP="RK3288"
	;; 
	"miniarm")
		DTB=rk3288-miniarm.dtb
		CHIP="RK3288"
	;; 
	"kylin")
		DTB=rk3036-kylin.dtb
		CHIP="RK3036"
	;;              
	*)
	echo "board '${BOARD}' not supported!"
	return
	;;
esac

echo Updating ${OPP}  for ${BOARD} board!

update_uboot()
{
	if [ $CHIP == "RK3288" ] ; then
		if [ $BOARD == "firefly" ] ; then
			echo "nothing"
		else
			echo "nothing"
		fi
	elif [ $CHIP == "RK3036" ]; then
		echo "nothing"
	elif [ $CHIP == "RK3399" ]; then
		echo "nothing"
	fi
}

update_kernel()
{
	if [ $CHIP == "RK3288" ] ; then
		if [ $BOARD == "firefly" ] ; then
			echo "nothing"
		else
			echo "nothing"
		fi
	elif [ $CHIP == "RK3036" ]; then
		echo "nothing"
	elif [ $CHIP == "RK3399" ]; then
		echo "nothing"
	fi
}

update_rootfs()
{
	if [ $CHIP == "RK3288" ] ; then
		if [ $BOARD == "firefly" ] ; then
			echo "nothing"
		else
			echo "nothing"
		fi
	elif [ $CHIP == "RK3036" ]; then
		echo "nothing"
	elif [ $CHIP == "RK3399" ]; then
		echo "nothing"
	fi
}

case ${OPP} in
	"uboot")
		update_uboot
	;;
	"kernel")
		update_kernel
	;;
	"rootfs")
		update_rootfs
                ;;
	*)
	echo "board '${BOARD}' not supported!"
	return
	;;
esac