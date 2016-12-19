## Usage

build kernel image:

	build/mk-kernel.sh rk3288-evb
    
build u-boot image:

	build/mk-uboot.sh rk3288-evb
    
build rootfs image:

	fllow readme in rk-rootfs-build
    
update image(unsupported):

	build/update.sh rk3288-evb all/kernel/uboot/rootfs
    
## Board list:

* rk3288-evb
* fennec
* miniarm
* firefly
* kylin
* rk3399-evb