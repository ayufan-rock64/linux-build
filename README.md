## Usage

build kernel image:

	build/mk-kernel.sh rk3288-evb
    
build u-boot image:

	build/mk-uboot.sh rk3288-evb
    
build rootfs image:

	fllow readme in rk-rootfs-build

build one system image:

	build/mk-image.sh -c rk3288 -t system -s 4000 -r rk-rootfs-build/linaro-rootfs.img

update image:

	emmc: build/flash_tool.sh  -p system  -i  out/system.img
	sdcard: build/flash_tool.sh -c rk3288  -d /dev/sdb -p system  -i  out/system.img 

## Board list:

* rk3288-evb
* fennec
* miniarm
* firefly
* kylin
* rk3399-evb