#!/bin/sh
#
# Simple script to create a rootfs for aarch64 platforms including support
# for Kernel modules created by the rest of the scripting found in this
# module.
#
# Use this script to populate the second partition of disk images created with
# the simpleimage script of this project.
#

set -e

BUILD="../build"
DEST="$1"
LINUX="$2"
DISTRO="$3"

if [ -z "$DEST" -o -z "$LINUX" ]; then
	echo "Usage: $0 <destination-folder> <linux-folder> [distro] $DEST"
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This script requires root."
	exit 1
fi

DEST=$(readlink -f "$DEST")
LINUX=$(readlink -f "$LINUX")

if [ ! -d "$DEST" ]; then
	echo "Destination $DEST not found or not a directory."
	exit 1
fi

if [ "$(ls -A -Ilost+found $DEST)" ]; then
	echo "Destination $DEST is not empty. Aborting."
	exit 1
fi

if [ -z "$DISTRO" ]; then
	DISTRO="arch"
fi

ROOTFS=""
UNTAR="bsdtar -xpf"

case $DISTRO in
	arch)
		ROOTFS="http://archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
		;;
	xenial)
		ROOTFS="http://cdimage.ubuntu.com/ubuntu-core/daily/current/xenial-core-arm64.tar.gz"
		;;
	*)
		echo "Unknown distribution: $DISTRO"
		exit 1
		;;
esac

TARBALL="$BUILD/$(basename $ROOTFS)"
if [ ! -e "$TARBALL" ]; then
	echo "Downloading $DISTRO rootfs tarball ..."
	wget -O "$TARBALL" "$ROOTFS"
fi

# Extract with BSD tar
echo -n "Extracting ... "
set -x
$UNTAR "$TARBALL" -C "$DEST"
echo "OK"

# Add qemu emulation.
cp /usr/bin/qemu-aarch64-static "$DEST/usr/bin"

do_chroot() {
	cmd="$@"
	chroot "$DEST" mount -t proc proc /proc || true
	chroot "$DEST" mount -t sysfs sys /sys || true
	chroot "$DEST" $cmd
	chroot "$DEST" umount /sys
	chroot "$DEST" umount /proc
}

# Run stuff in new system.
case $DISTRO in
	arch)
		# Cleanup preinstalled Kernel
		mv "$DEST/etc/resolv.conf" "$DEST/etc/resolv.conf.dist"
		cp /etc/resolv.conf "$DEST/etc/resolv.conf"
		do_chroot pacman -Rsn --noconfirm linux-aarch64 || true
		do_chroot pacman -Sy --noconfirm dosfstools || true
		rm -f "$DEST/etc/resolv.conf"
		mv "$DEST/etc/resolv.conf.dist" "$DEST/etc/resolv.conf"
		;;
	xenial)
		mv "$DEST/etc/resolv.conf" "$DEST/etc/resolv.conf.dist"
		cp /etc/resolv.conf "$DEST/etc/resolv.conf"
		do_chroot apt-get -y update
		do_chroot apt-get -y install dosfstools
		rm -f "$DEST/etc/resolv.conf"
		mv "$DEST/etc/resolv.conf.dist" "$DEST/etc/resolv.conf"
		;;
	*)
		;;
esac

# Bring back folders
mkdir -p "$DEST/lib/modules"

# Create fstab
cat <<EOF > "$DEST/etc/fstab"
# <file system>	<dir>	<type>	<options>			<dump>	<pass>
/dev/mmcblk0p1	/boot	vfat	defaults			0		2
/dev/mmcblk0p2	/	ext4	defaults,noatime		0		1
EOF

# Install Kernel modules
make -C $LINUX ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH="$DEST"

# Install extra mali module if found in Kernel tree.
if [ -e $LINUX/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali/mali.ko ]; then
	v=$(ls $DEST/lib/modules/)
	mkdir "$DEST/lib/modules/$v/kernel/extramodules"
	cp -v $LINUX/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali/mali.ko $DEST/lib/modules/$v/kernel/extramodules
	depmod -b $DEST $v
fi

# Clean up
rm -f "$DEST/usr/bin/qemu-aarch64-static"

echo "Done - installed rootfs to $DEST"
