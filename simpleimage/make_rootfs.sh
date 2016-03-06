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

# Prevent services from starting
cat > "$DEST/usr/sbin/policy-rc.d" <<EOF
#!/bin/sh
exit 101
EOF
chmod a+x "$DEST/usr/sbin/policy-rc.d"

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
		do_chroot pacman -Sy --noconfirm dosfstools curl xz || true
		rm -f "$DEST/etc/resolv.conf"
		mv "$DEST/etc/resolv.conf.dist" "$DEST/etc/resolv.conf"
		;;
	xenial)
		rm "$DEST/etc/resolv.conf"
		cp /etc/resolv.conf "$DEST/etc/resolv.conf"
		cat > "$DEST/second-phase" <<EOF
#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install dosfstools ubuntu-minimal curl xz-utils
apt-get -y remove --purge ureadahead
adduser --gecos ubuntu --disabled-login ubuntu --uid 1000
chown -R 1000:1000 /home/ubuntu
echo "ubuntu:ubuntu" | chpasswd
usermod -a -G sudo ubuntu
EOF
		chmod +x "$DEST/second-phase"
		do_chroot /second-phase
		cat > "$DEST/etc/network/interfaces.d/eth0" <<EOF
auto eth0
iface eth0 inet dhcp
EOF
		cat > "$DEST/etc/hosts" <<EOF
127.0.0.1 localhost
127.0.1.1 localhost.localdomain

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
		cat > "$DEST/etc/systemd/system/eth0-mackeeper.service" <<EOF
[Unit]
Description=Fix eth0 mac address to uEnv.txt

[Service]
Type=oneshot
After=systemd-modules-load.service
After=local-fs.target
ExecStart=/usr/local/sbin/pine64_eth0-mackeeper.sh

[Install]
WantedBy=multi-user.target
EOF
		do_chroot systemctl enable eth0-mackeeper
		cat > "$DEST/etc/systemd/system/cpu-corekeeper.service" <<EOF
[Unit]
Description=CPU corekeeper

[Service]
ExecStart=/usr/local/sbin/pine64_corekeeper.sh

[Install]
WantedBy=multi-user.target
EOF
		do_chroot systemctl enable cpu-corekeeper
		sed -i 's|After=rc.local.service|#\0|;' "$DEST/lib/systemd/system/serial-getty@.service"
		rm -f "$DEST/second-phase"
		rm -f "$DEST/etc/resolv.conf"
		do_chroot ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
		;;
	*)
		;;
esac

# Bring back folders
mkdir -p "$DEST/lib/modules"
mkdir -p "$DEST/usr"

# Create fstab
cat <<EOF > "$DEST/etc/fstab"
# <file system>	<dir>	<type>	<options>			<dump>	<pass>
/dev/mmcblk0p1	/boot	vfat	defaults			0		2
/dev/mmcblk0p2	/	ext4	defaults,noatime		0		1
EOF

# Install Kernel modules
make -C $LINUX ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH="$DEST"
# Install Kernel firmware
make -C $LINUX ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- firmware_install INSTALL_MOD_PATH="$DEST"
# Install Kernel headers
make -C $LINUX ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH="$DEST/usr"

# Install extra mali module if found in Kernel tree.
if [ -e $LINUX/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali/mali.ko ]; then
	v=$(ls $DEST/lib/modules/)
	mkdir "$DEST/lib/modules/$v/kernel/extramodules"
	cp -v $LINUX/modules/gpu/mali400/kernel_mode/driver/src/devicedrv/mali/mali.ko $DEST/lib/modules/$v/kernel/extramodules
	depmod -b $DEST $v
fi

# Install platform scripts
mkdir -p "$DEST/usr/local/sbin"
cp -av ./platform-scripts/* "$DEST/usr/local/sbin"
chown root.root "$DEST/usr/local/sbin/"*
chmod 755 "$DEST/usr/local/sbin/"*

# Set kernel update version
do_chroot /usr/local/sbin/pine64_update_kernel.sh --mark-only

# Clean up
rm -f "$DEST/usr/bin/qemu-aarch64-static"
rm -f "$DEST/usr/sbin/policy-rc.d"

echo "Done - installed rootfs to $DEST"
