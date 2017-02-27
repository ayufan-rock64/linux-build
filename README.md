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

	eMMC: build/flash_tool.sh   -c rk3288 -p system  -i  out/system.img
	sdcard: build/flash_tool.sh -c rk3288  -d /dev/sdb -p system  -i  out/system.img 

Need to boot into maskrom(If booting into rkusb, it won't work) before flashing to eMMC.