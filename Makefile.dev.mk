.PHONY: help
help:
	@echo Available targets:
	@grep -h '^.PHONY: .*#' Makefile* | cut -d: -f2- | expand -t20 | sort
	@echo
	@echo Extra targets:
	@echo " " $$(grep -h '^.PHONY: [^#]*$$' Makefile* | cut -d: -f2- | sort)

clean:
	rm -f *.img.tmp *.img.xz *-packages.txt *.deb

dockerfiles:
	git clone https://github.com/ayufan-rock64/dockerfiles.git

linux-rootfs:
	git clone https://github.com/ayufan-rock64/linux-rootfs.git

linux-mainline-u-boot:
	git clone https://github.com/ayufan-rock64/linux-mainline-u-boot.git

linux-mainline-kernel:
	git clone https://github.com/ayufan-rock64/linux-mainline-kernel.git

linux-package:
	git clone https://github.com/ayufan-rock64/linux-package.git

rockchip-rkbin:
	git clone https://github.com/ayufan-rock64/rkbin.git rockchip-rkbin

repos: dockerfiles linux-rootfs linux-mainline-u-boot linux-package linux-mainline-kernel rockchip-rkbin

linux-mainline-u-boot/.git/refs/remotes/upstream: linux-mainline-u-boot
	-git -C linux-mainline-u-boot remote add upstream https://github.com/u-boot/u-boot.git
	git -C linux-mainline-u-boot fetch upstream

linux-mainline-kernel/.git/refs/remotes/upstream: linux-mainline-kernel
	-git -C linux-mainline-kernel remote add upstream https://github.com/torvalds/linux.git
	git -C linux-mainline-kernel fetch upstream

rockchip-rkbin/.git/refs/remotes/upstream: rockchip-rkbin
	-git -C rockchip-rkbin remote add upstream https://github.com/rockchip-linux/rkbin.git
	git -C rockchip-rkbin fetch upstream

repos: linux-mainline-u-boot/.git/refs/remotes/upstream linux-mainline-kernel/.git/refs/remotes/upstream rockchip-rkbin/.git/refs/remotes/upstream
